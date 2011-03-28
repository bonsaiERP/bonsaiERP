# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org

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

  attr_accessor  :payment_destroy, :to_account, :to_amount, :to_exchange_rate
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

  def self.get_by_option(option)
    ledgers = includes(:payment, :transaction, :contact) 
    case option
    when 'false' then ledgers.pendent
    when 'true' then ledgers.conciliated
    else
      ledgers
    end
  end


private
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
