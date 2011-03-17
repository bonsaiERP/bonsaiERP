# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Payment < ActiveRecord::Base
  # include helper for account_ledger text
  include ActionView::Helpers::NumberHelper

  acts_as_org

  attr_reader :pay_plan, :updated_pay_plan_ids
  attr_protected :state
  STATES = ['conciliation', 'paid']


  # callbacks
  after_initialize  :set_defaults,      :if => :new_record?
  before_validation :set_exchange_rate
  before_create     :set_currency_id,   :if => :new_record?
  before_create     :set_cash_amount,   :if => :transaction_cash?
  before_save       :set_state,         :if => 'state.blank?'

  # update_pay_plan must run before update_transaction
  after_create  :create_account_ledger
  after_save    :update_pay_plan#,    :if => :paid?
  after_save    :update_transaction#, :if => :paid?
  after_destroy :update_transaction

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
  validates_numericality_of :exchange_rate, :greater_than => 0, :if => :other_currency?

  validate              :valid_payment_amount, :if => :active?
  validate              :valid_amount_or_interests_penalties, :if => :active?

  # scopes
  scope :active,       where(:active => true)
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

  # Tells if the payment is in a differenc currency of the transaction
  def other_currency?
    if currency_id.present?
      transaction.currency != account.currency_id
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
  def amount_currency
    (amount + interests_penalties) * exchange_rate
  end

private
  def set_defaults
    self.amount              ||= 0
    self.interests_penalties ||= 0
    self.active                = true if active.nil?
    self.exchange_rate       ||= 1.0
    self.currency_id           = transaction.currency_id
  end

  def update_transaction
    unless destroyed?
      transaction.add_payment(amount)
    else
      transaction.substract_payment(amount)
    end

    transaction.update_transaction_payment_date
  end

  def set_currency_id
    self.currency_id = transaction.currency_id
  end

  # Updates the related pay_plans of a transaction setting to pay
  # according to the amount and interest penalties
  def update_pay_plan
    amount_to_pay         = 0
    interest_to_pay       = 0
    created_pay_plan      = nil
    amount_to_pay         = amount
    interest_to_pay       = interests_penalties
    @updated_pay_plan_ids = []

    transaction.pay_plans.unpaid.each_with_index do |pp, i|
      amount_to_pay += - pp.amount
      interest_to_pay += - pp.interests_penalties

      pp.update_attribute(:paid, true)
      @updated_pay_plan_ids << pp.id

      if amount_to_pay <= 0
        @pay_plan = create_pay_plan(amount_to_pay, interest_to_pay, pp) if amount_to_pay < 0 or interest_to_pay < 0
        break
      end
    end
  end

  # Creates a new pay_plan
  # @param Decimal amt
  # @param Decimal int_pen
  # @param PayPlan pp
  def create_pay_plan(amt, int_pen, pp)
    amt = amt < 0 ? -1 * amt : 0
    int_pen = int_pen < 0 ? -1 * int_pen : 0
    p = PayPlan.create( :transaction_id => transaction_id, :amount => amt,                :interests_penalties => int_pen,
                        :payment_date => pp.payment_date,  :alert_date => pp.alert_date )
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
  def create_account_ledger
    if transaction.type == "Income"
      tot, income = [ amount_currency, true ]
    else
      tot, income = [-amount_currency, true ]
    end

    AccountLedger.create(:account_id => account_id, :payment_id => id, 
                         :currency_id => account.currency_id, :contact_id => transaction_contact_id,
                         :amount => tot, :date => date, :income => income, :transaction_id => transaction_id,
                         :description => get_account_ledger_text, :reference => reference
                        ) {|al| al.conciliation = get_conciliation }
  end

  # Returns the conciliation value
  def get_conciliation
    "CashRegister" == account_type
  end

  # Creates the account_ledger text
  def get_account_ledger_text
    txt = get_exchange_rate_text
    case
    when 'Income'  then "Cobro venta #{transaction_ref_number}#{txt}"
    when 'Buy'     then "Pago compra #{transaction_ref_number}#{txt}"
    when 'Expense' then "Pago gasto #{transaction_ref_number}#{txt}"
    end
  end

  # Text for the account_ledger
  def get_exchange_rate_text
    unless transaction.currency_id == account.currency_id
      #cur = Currency.find(account.currency_id)
      er = number_to_currency(exchange_rate)
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
    if transaction.currency_id == account.currency_id or account_id.blank?
      self.exchange_rate = 1
    elsif exchange_rate == 0 or exchange_rate.blank? and account_id.present?
      self.exchange_rate = CurrencyRate.active.find(account.currency_id).rate
    end
  end
end
