# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Payment < ActiveRecord::Base
  # include helper for account_ledger text
  include ActionView::Helpers::NumberHelper

  acts_as_org

  attr_reader :pay_plan, :updated_pay_plan_ids, :account_ledger_created

  attr_reader :updated_account_ledger

  attr_protected :state

  STATES = ['conciliation', 'paid']


  # callbacks
  after_initialize  :set_defaults,      :if => :new_record?
  before_create     :set_currency_id,   :if => :new_record?
  before_create     :set_cash_amount,   :if => :transaction_cash?
  before_validation :set_exchange_rate
  before_save       :set_state,         :if => 'state.blank?'
  before_destroy    :destroy_and_create_pay_plan

  # update_pay_plan must run before update_transaction
  after_create   :create_account_ledger
  after_save     :update_pay_plan#,    :if => :paid?
  after_save     :update_transaction,    :unless => :updated_account_ledger?
  after_destroy  :destroy_account_ledger
  after_destroy  :update_transaction

  # relationships
  belongs_to :transaction
  belongs_to :account
  belongs_to :currency
  belongs_to :contact
  has_one    :account_ledger

  delegate  :state,        :type,       :cash,  :cash?,      :real_state,
            :balance,      :contact_id, :paid?, :ref_number, :type,
            :payment_date,
            :to => :transaction, :prefix => true

  delegate  :id, :to => :account_ledger, :prefix => true

  delegate :name, :symbol, :to => :currency, :prefix => true

  delegate :type, :name, :number, :to => :account, :prefix => true

  # validations
  validates_presence_of     :account_id, :transaction_id, :reference, :date
  validates                 :exchange_rate, :numericality => {:greater_than => 0}, :presence => true

  validate              :valid_payment_amount
  validate              :valid_amount_or_interests_penalties

  # scopes
  default_scope where(:active => true)

  scope :paid,         where(:state => 'paid')
  scope :conciliation, where(:state => 'conciliation')

  # Creates methods of paid? conciliation?
  STATES.each do |st|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{st}?
        "#{st}" == state
      end
    CODE
  end

  alias_method :original_destroy, :destroy


  # Tells if the payment is in a differenc currency of the transaction
  def different_currency?
    if currency_id.present?
      if account_id.present?
        transaction.currency != account.currency_id
      else
        false
      end
    end
  end

  # Overide the dault to_json method
  def to_json
    self.attributes.merge(
      :updated_pay_plan_ids     => @updated_pay_plan_ids,
      :currency_symbol          => currency_symbol,
      :pay_plan                 => @pay_plan,
      :account                  => account.to_s,
      :total_amount             => total_amount,
      :transaction_real_state   => transaction_real_state,
      :transaction_balance      => transaction_balance,
      :transaction_payment_date => transaction_payment_date,
      :account_ledger_id        => account_ledger_id
    ).to_json
  end

  # Sums the amount plus the interests and penalties
  def total_amount
    amount + interests_penalties
  end

  # Nulls a payment
  def null_payment
    if active and not transaction_paid?
      self.active = false
      self.save
    end
  end

  # amount in the currency
  def total_amount_currency
    (amount + interests_penalties) * exchange_rate
  end

  # the account ledger sets this if no
  def set_updated_account_ledger(value = true)
    @updated_account_ledger = value
  end

private

  def updated_account_ledger?
    not @updated_account_ledger.blank?
  end

  def set_defaults
    self.amount              ||= 0
    self.interests_penalties ||= 0
    self.active                = true
    self.currency_id           = transaction.currency_id
    self.exchange_rate = 1 if exchange_rate.blank?
  end

  def destroy_and_create_pay_plan
    d = Date.today
    create_pay_plan(amount, interests_penalties, d, d - 5.days)
  end

  def update_transaction
    unless destroyed?
      transaction.add_payment(amount)
    else
      transaction.substract_payment(amount)
    end
  end

  def set_currency_id
    self.currency_id = transaction.currency_id
  end

  # Updates the related pay_plans of a transaction setting to pay
  # according to the amount and interest penalties
  def update_pay_plan
    created_pay_plan      = nil
    amount_to_pay         = amount
    interest_to_pay       = interests_penalties
    @updated_pay_plan_ids = []

    transaction.pay_plans.unpaid.each_with_index do |pp, i|
      amount_to_pay += - pp.amount
      interest_to_pay += - pp.interests_penalties

      pp.update_attribute(:paid, true)
      @updated_pay_plan_ids << pp.id

      if amount_to_pay < 0
        @pay_plan = create_pay_plan(-amount_to_pay, -interest_to_pay, pp.payment_date, pp.alert_date) if amount_to_pay < 0 or interest_to_pay < 0
        break
      end
    end
  end

  # Creates a new pay_plan
  # @param Decimal amt
  # @param Decimal int_pen
  # @param PayPlan pp
  def create_pay_plan(amt, int_pen, pp_pdate, pp_adate)
    int_pen = int_pen < 0 ? -1 * int_pen : 0
    pp = PayPlan.create!( :transaction_id => transaction_id, :amount => amt, :interests_penalties => int_pen,
                        :payment_date => pp_pdate,  :alert_date => pp_adate )
  end

  def valid_payment_amount
    if amount > transaction.balance
      self.errors.add(:amount, "La cantidad ingresada es mayor que el saldo por pagar.")
    end
  end

  # Checks that anny of the values is set to greater than 0
  def valid_amount_or_interests_penalties
    if self.amount <= 0 and interests_penalties <= 0
      self.errors.add(:amount, "Debe ingresar una cantidad mayor a 0 para Cantidad o Intereses/Penalidades")
    end
  end

  # Creates an account ledger for the account and payment
  # indicates the record has been destroyed
  def create_account_ledger(destroy = false)
    tot = total_amount_currency
    if transaction.type == "Income"
      income = true
    else
      income = false
    end

    if destroy
      income = not(income)
    end

    create_account_ledger_record(tot, income, get_conciliation, id)
  end

  # Destorys the account ledger in case it is not conciliated
  # In case that is conciliated it creates a record with negative value
  def destroy_account_ledger
    if account_ledger.present?
      unless account_ledger.conciliation?
        account_ledger.destroy 
      else
        create_account_ledger(true)
      end
    end
  end

  # Creates a new record based on the paramas
  # @param Decimal
  # @param [True, False]
  # @param [True, False]
  # @param [Integer, Nil]
  def create_account_ledger_record(tot, income, conciliation, id)
    @account_ledger_created = AccountLedger.create(
      :account_id => account_id, :payment_id => id, 
                         :currency_id => account.currency_id, :contact_id => transaction_contact_id,
                         :amount => tot, :date => date, :income => income, :transaction_id => transaction_id,
                         :description => get_account_ledger_text, :reference => reference
                        ) {|al| al.conciliation = conciliation }
    
  end

  # Returns the conciliation value
  def get_conciliation
    "CashRegister" == account_type
  end

  # Creates the account_ledger text
  def get_account_ledger_text
    txt = get_exchange_rate_text
    del = ""
    if destroyed?
      del = "Borrado de "
    end

    case
    when 'Income'  then "#{del}Cobro venta #{transaction_ref_number}#{txt}"
    when 'Buy'     then "#{del}Pago compra #{transaction_ref_number}#{txt}"
    when 'Expense' then "#{del}Pago gasto #{transaction_ref_number}#{txt}"
    end
  end

  # Text for the account_ledger
  def get_exchange_rate_text
    unless transaction.currency_id == account.currency_id
      #cur = Currency.find(account.currency_id)
      er = number_to_currency(exchange_rate, :precision => 4)
      " Tipo de cambio 1 #{transaction.currency_name} = #{er} #{account.currency_name.pluralize}"
    end
  end

  # Sets the amount for cash
  def set_cash_amount
    self.amount = transaction_balance
  end

  # Sets the state accoording to the account
  def set_state
    case account_type
    when "Bank"         then self.state = "conciliation"
    when "CashRegister" then self.state = "paid"
    end
  end

  # Sets the exchange rate in case it's ovwritten
  def set_exchange_rate
    if account_id.blank? or transaction.currency_id == account.currency_id
      self.exchange_rate = 1
    end
  end

end
