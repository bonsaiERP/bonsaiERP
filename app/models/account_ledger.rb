# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  attr_protected :conciliation

  has_many :account_ledger_details, :dependent => :destroy
  accepts_nested_attributes_for :account_ledger_details
  #acts_as_org

  #include ActionView::Helpers::NumberHelper

  #alias original_destroy destroy

  #def destroy; false; end
  ## callbacks
  #before_create     :set_conciliation
  #before_create     :set_personal
  #before_save       :set_income
  #before_save       :set_creator_id
  #before_save       :set_currency
  #after_save        :update_payment,         :if => :payment?
  #after_save        :update_account_balance, :if => :conciliation?
  ## Do not use *_destroy callbacks due to how the transaction block works and in many times it updates more than one record

  ## relationships
  #belongs_to :account
  #belongs_to :payment
  #belongs_to :contact
  #belongs_to :currency
  #belongs_to :transaction
  #belongs_to :transferer, :class_name => 'AccountLedger', :foreign_key => :account_ledger_id

  #belongs_to :creator,           :class_name => 'User'
  #belongs_to :approver,          :class_name => 'User'
  #belongs_to :nuller,            :class_name => 'User'
  #belongs_to :personal_approver, :class_name => 'User'

  ##has_many :personal_comments, :dependent => :destroy
  #has_one :personal_comment
  #accepts_nested_attributes_for :personal_comment

  #attr_accessor  :payment_destroy, :to_account, :to_exchange_rate, :to_amount_currency, :comment
  #attr_reader    :transference, :destroyed, :no_personal
  #attr_protected :conciliation, :personal, :active, :creator_id, :nuller_id, :personal_approver_id


  ## validations
  #validates_presence_of :account_id, :date, :amount, :contact_id
  #validates_numericality_of :amount
  #validates :reference, :presence => true, :length => {:maximum => 200}
  #validate :valid_organisation_account

  ## transference
  #with_options :if => :transference? do |al|
  #  al.validate :validate_to_account
  #  al.validate :validate_to_exchange_rate
  #  al.validate :validate_to_amount
  #end

  ## delegates
  #delegate :name, :number, :type, :to => :account, :prefix => true
  #delegate :amount, :interests_penalties, :date, :state, :to => :payment, :prefix => true
  #delegate :name, :symbol, :to => :currency, :prefix => true

  ## scopes
  #scope :pendent,          where(:conciliation => false)
  #scope :conciliated,      where(:conciliation => true)
  #scope :active,           where(:active => true)
  #scope :inactive,         where(:active => false)
  #scope :personal_pendant, where(:personal => 'personal')
  #scope :personal,         where(:personal => 'approved')

  ## Updates the conciliation state
  #def conciliate_account
  #  if account_ledger_id.present?
  #    conciliate_transference
  #  else
  #    conciliate_account_ledger
  #  end
  #end

  ## conciliation of account ledger
  #def conciliate_account_ledger
  #  self.approver_id  = UserSession.current_user.id
  #  unless income?
  #    errors.add(:base, "El monto a conciliar es mayor al total en la cuenta") if amount.abs > account.total_amount
  #  end

  #  if errors.blank?
  #    self.conciliation = true
  #    self.save
  #  else
  #    false
  #  end
  #end

  ## Conciliation for transference
  #def conciliate_transference
  #  saved = true
  #  AccountLedger.transaction do
  #    saved = false unless self.conciliate_account_ledger
  #    if saved
  #      saved = transferer.conciliate_account_ledger
  #    end
  #    raise ActiveRecord::Rollback unless saved
  #  end
  #  saved
  #end

  ## Returns a scope based on the option
  #def self.get_by_option(option)
  #  ledgers = includes(:payment, :transaction, :contact, :creator, :approver, :nuller) 
  #  case option
  #  when 'false'    then ledgers.pendent
  #  when 'true'     then ledgers.conciliated
  #  when 'nil'      then ledgers.inactive
  #  when 'personal' then ledgers.personal_pendant
  #  when 'approved' then ledgers.personal
  #  else
  #    ledgers
  #  end
  #end

  ## Creates transference
  #def create_transference
  #  @transference         = true
  #  self.reference        = 'Transferencia'
  #  self.to_exchange_rate = to_exchange_rate.to_f

  #  if valid?
  #    to_amount_currency = to_exchange_rate.round(4) * amount

  #    txt = ""
  #    unless account_to.currency_id == account.currency_id
  #      txt = ", tipo de cambio 1 #{account.currency} = #{number_to_currency to_exchange_rate, :precision => 4}" 
  #      txt << " #{account.currency_plural}"
  #    end

  #    self.income      = false
  #    self.description = "Transferencia a cuenta #{Account.find(to_account)}#{txt}"
  #    self.personal = 'no'

  #    self.transferer = AccountLedger.new(self.attributes.merge(
  #      :account_id => to_account, 
  #      :amount => amount * to_exchange_rate,
  #      :description => "Transferencia desde cuenta #{account}#{txt}"
  #      )
  #    )

  #    self.transferer.income   = true
  #    self.transferer.personal = 'no'

  #    res = true
  #    AccountLedger.transaction do
  #      res = self.save
  #      res = res and self.transferer.update_attribute(:account_ledger_id, self.id)
  #      raise AcitveRecord::Rollback unless res
  #    end

  #    res 
  #  else
  #    false
  #  end
  #end

  #def show_exchange_rate?
  #  if to_account.present?
  #    if errors[:to_account].blank? and account.currency_id != account_to.currency_id
  #      true
  #    else
  #      false
  #    end
  #  else
  #    false
  #  end
  #end

  #def destroyed?
  #  @destroyed
  #end

  ## Tells if personal == 'personal'
  #def personal?
  #  personal == 'personal'
  #end

  #def is_personal?
  #  ['personal', 'approved'].include?(personal)
  #end

  ## Updates all data and changes active = false
  #def destroy_account_ledger
  #  if can_destroy?
  #    case 
  #    when payment_id.present?        then destroy_payment
  #    when account_ledger_id.present? then destroy_related
  #    else
  #      unset_active
  #    end
  #  else
  #    false
  #  end
  #end

  ## Approves the account for personal
  #def approve_personal(comment)
  #  self.personal_approver_id     = UserSession.user_id
  #  self.personal                 = 'approved'
  #  self.personal_comment_attributes = {:comment => comment}
  #  self.save
  #end

  ## Checks if ir can be destroyed
  #def can_destroy?
  #  if conciliation or not(active)
  #    false
  #  else
  #    true
  #  end
  #end

  #def set_transference(val)
  #  @transference = val
  #end


pr#ivate
  #
  ## returns the account_to, using to_account id
  #def account_to
  #  if to_account.present? and @acc_to.nil?
  #    @acc_to = Account.org.where(:id => to_account)
  #    if @acc_to.any?
  #      @acc_to = @acc_to.first
  #    else
  #      false
  #    end
  #  else
  #    @acc_to
  #  end
  #end

  ## validates the account
  #def validate_to_account
  #  unless account_to
  #    errors.add(:to_account, "Debe seleccionar una cuenta válida")
  #  else
  #    self.to_exchange_rate = 1 if account_to.currency_id == account.currency_id
  #  end
  #end

  ## validates that the exchange rate is set
  #def validate_to_exchange_rate
  #  if account_to and account.currency_id != account_to.currency_id
  #    if to_exchange_rate <= 0
  #      errors.add(:to_exchange_rate, "Debe ingresar un valor mayor que 0")
  #    end
  #  end
  #end

  #def validate_to_amount
  #  if amount.to_f > 0
  #    errors.add(:amount, "La cantidad que ingreso es mayor a la disponible") if (amount > account.total_amount)
  #  end
  #end

  ##def set_defaults
  ##  self.date ||= Date.today
  ##  self.conciliation = self.conciliation.nil? ? false : conciliation
  ##end

  #def payment?
  #  payment_id.present? and not(conciliation?)
  #end

  ##  set the amount depending if income or outcome
  #def set_income
  #  self.income = false if income.blank?
  #  if (not(income) and amount > 0) or (income and amount < 0)
  #    self.amount = -1 * amount
  #  end
  #  true
  #end

  #def set_currency
  #  self.currency_id = account.currency_id if account_id.present?
  #end

  ## Updates the payment state, without validation
  #def update_payment
  #  if conciliation? and payment.present? and not(payment_state == 'paid')
  #    payment.state = 'paid'
  #    payment.save(:validate => false)
  #  end
  #end

  ## Updates the total amount for the account
  #def update_account_balance
  #  self.account.total_amount = (self.account.total_amount + amount)
  #  self.account.save
  #end

  #def payment?
  #  payment_id.present?
  #end

  #def valid_organisation_account
  #  unless Account.org.map(&:id).include?(account_id)
  #    logger.warn "El usuario #{UserSession.user_id} trato de hackear account_ledger"
  #    errors.add(:base, "Ha seleccionado una cuenta inexistente regrese a la cuenta")
  #  end
  #end

  #def set_creator_id
  #  self.creator_id = UserSession.current_user.id
  #end

  ## destroys a payment, in case the payment calls for destroying the account_ledger
  ## the if payment.present? will control if the payment was not already destroyed
  #def destroy_payment
  #  dest = true

  #  self.class.transaction do
  #    self.active    = false
  #    self.nuller_id = UserSession.user_id
  #    dest           = self.save

  #    payment.active = false
  #    dest = dest and payment.save

  #    raise ActiveRecord::Rollback unless dest
  #  end

  #  @destroyed = dest
  #end


  ## Destroys related for transference or validates if conciliation
  #def destroy_related
  #  dest = true

  #  self.class.transaction do
  #    self.active    = false
  #    self.nuller_id = UserSession.user_id
  #    dest           = self.save

  #    transferer.active = false
  #    dest = dest and transferer.save
  #    raise ActiveRecord::Rollback unless dest
  #  end

  #  @destroyed = dest
  #end

  #def set_conciliation
  #  self.conciliation = false if conciliation.blank?
  #  true
  #end

  ## Updates active state for destroy
  #def unset_active
  #  self.active = false
  #  @destroyed = self.save
  #end
  #  
  ## Sets the variable if the selected contact is a Staff  
  #def set_personal
  #  if self.personal.blank?
  #   self.personal = contact.is_a?(Staff) ? 'personal' : 'no'
  #  end
  #end

  #def transference?
  #  if transference.nil? or transference == false
  #    false
  #  else
  #    true
  #  end
  #end
end
