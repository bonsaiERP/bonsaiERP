# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org

  include ActionView::Helpers::NumberHelper

  # callbacks
  after_initialize :set_defaults
  before_save      :set_income              
  before_save      :set_currency
  after_save       :update_payment,         :if => :payment?
  after_save       :update_account_balance, :if => :conciliation?
  after_destroy    :destroy_payment,        :if => :payment?


  # relationships
  belongs_to :account
  belongs_to :payment
  belongs_to :contact
  belongs_to :currency
  belongs_to :transaction

  attr_accessor  :payment_destroy, :to_account, :to_amount, :to_exchange_rate, :to_amount_currency
  attr_protected :conciliation

  # validations
  validates_presence_of :account_id, :date, :reference, :amount, :contact_id
  validates_numericality_of :amount, :greater_than => 0, :unless => :conciliation?
  validate :valid_organisation_account

  # delegates
  delegate :name, :number, :type, :to => :account, :prefix => true
  delegate :amount, :interests_penalties, :date, :state, :to => :payment, :prefix => true
  delegate :name, :symbol, :to => :currency, :prefix => true

  # scopes
  scope :pendent,     where(:conciliation => false)
  scope :conciliated, where(:conciliation => true)

  # Updates the conciliation state
  def conciliate_account
    self.conciliation = true
    self.save
  end

  # Returns a scope based on the option
  def self.get_by_option(option)
    ledgers = includes(:payment, :transaction, :contact) 
    case option
    when 'false' then ledgers.pendent
    when 'true' then ledgers.conciliated
    else
      ledgers
    end
  end

  # Creates transference
  def create_transference(params)
    self.to_amount = to_amount.to_f
    self.to_exchange_rate = to_exchange_rate.to_f

    validate_to_amount
    validate_to_account
    validate_to_exchange_rate
        
    if errors.blank?
      to_amount_currency = to_exchange_rate.round(4) * to_amount

      AccountLedger.transaction do
        txt = ""
        unless @ac2.currency_id == account.currency_id
          txt = ", tipo de cambio 1 #{account.currency} = #{number_to_currency to_exchange_rate, :precision => 4}" 
          txt << " #{account.currency_plural}"
        end

        ac1 = AccountLedger.new(:amount => to_amount, :account_id => account_id, :date => Date.today, :income => false, :reference => 'Transferencia', :description => "Transferencia a cuenta #{@ac2}#{txt}")
        ac2 = AccountLedger.new(:amount => to_amount_currency, :account_id => to_account, :date => Date.today, :income => true, :reference => "Transferencia", :description => "Transferencia desde cuenta #{account},#{txt}")
        
        raise ActiveRecord::Rollback unless ac1.save(:validate => false)
        raise ActiveRecord::Rollback unless ac2.save(:validate => false)
      end
      true
    end
  end

  def show_exchange_rate?
    if to_account.present?
      if errors[:to_account].blank? and account.currency_id != @ac2.currency_id
        true
      else
        false
      end
    else
      false
    end
  end

private
  # validates transference amount
  def validate_to_amount
    if to_amount > account.total_amount
      errors.add(:to_amount, "La cantidad que desea transferir es mayor a la que tiene en la cuenta")
    end
  end

  # validates the account
  def validate_to_account
    @ac2 = Account.org.where(:id => to_account)
    unless @ac2.any?
      errors.add(:to_account, "Debe seleccionar una cuenta válida")
    end
    if @ac2.any?
      @ac2 = @ac2.first
      self.to_exchange_rate = 1 if @ac2.currency_id == account.currency_id
    end
  end

  # validates that the exchange rate is set
  def validate_to_exchange_rate
    unless errors[:account_to].any?
      to_acc = Account.org.find(to_account)
      unless account.currency_id == to_acc.currency_id
        if to_exchange_rate <= 0
          errors.add(:to_exchange_rate, "Debe ingresar un valor mayor que 0")
        end
      end      
    end
  end

  def set_defaults
    self.date ||= Date.today
    self.conciliation = self.conciliation.nil? ? false : conciliation
  end

  def payment?
    payment_id.present? and conciliation?
  end

  #  set the amount depending if income or outcome
  def set_income
    self.income = false if income.blank?
    if (not(income) and amount > 0) or (income and amount < 0)
      self.amount = -1 * amount
    end
    true
  end

  def set_currency
    self.currency_id = account.currency_id if account_id.present?
  end

  # Updates the payment state, without triggering any callbacks
  def update_payment
    if conciliation == true and payment.present? and not(payment_state == 'paid')
      payment.state = 'paid'
      payment.set_updated_account_ledger(true)
      payment.save(:validate => false)
    end
  end

  # Updates the total amount for the account
  def update_account_balance
    self.account.total_amount = (self.account.total_amount + amount)
    self.account.save
  end

  def payment?
    payment_id.present?
  end

  # destroys a payment, in case the payment calls for destroying the account_ledger
  # the if payment.present? will control if the payment was not already destroyed
  def destroy_payment
    payment.destroy if payment.present?
  end

  def valid_organisation_account
    unless Account.org.map(&:id).include?(account_id)
      logger.warn "El usuario #{UserSession.user_id} trato de hackear account_ledger"
      errors.add(:base, "Ha seleccionado una cuenta inexistente regrese a la cuenta")
    end
  end
end
