# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlan < ActiveRecord::Base
  acts_as_org
  after_initialize :set_defaults
  before_save      :set_currency_id
  before_destroy   :check_if_paid
  #after_save :update_transaction
  #after_save :update_transaction_payment_date
  #after_destroy :update_transaction
  
  # repeat repeats the pay_plan over until it fills the balance of a transaction
  attr_accessor :repeat, :destroy_in_list
  attr_protected :destroy_in_list

  STATES = ["valid", "delayed", "applied"]

  # relationships
  belongs_to :transaction
  belongs_to :currency

  # delegations
  delegate :currency_id, :pay_plans_balance, :pay_plans_total, :payment_date, :real_state, :paid?, :cash, :ref_number, :draft?, :balance, :state, :type,
    :to => :transaction, :prefix => true
  delegate :name, :symbol, :to => :currency, :prefix => true

  # validations
  validate :valid_income_or_interests_penalties_filled
  #validate :valid_pay_plans_total_amount
  validates_presence_of :payment_date, :alert_date
  validate :valid_payment_date_alert_date

  # scopes
  scope :unpaid, where(:paid => false)
  scope :paid,   where(:paid => true)
  scope :date,   lambda {|d| where(["payment_date <= ?", d]) }
  scope :in,     where(:ctype => "Income")
  scope :out,    where(:ctype => ["Buy", "Expense"])

  def self.in_to_currency(currency_id, date)
    sum_with_exchange_rate( PayPlan.org.unpaid.in.date(date), currency_id )
  end

  def self.out_to_currency(currency_id, date)
    sum_with_exchange_rate( PayPlan.org.unpaid.out.date(date), currency_id )
  end

  # Sums a list of objects with the exchange rate
  def self.sum_with_exchange_rate(list, currency_id)
    @exchange_rates ||= CurrencyRate.current_hash
    tot = 0

    list.each do |pp|
      if currency_id == pp.currency_id
        tot += pp.amount
      else
        tot += pp.amount * @exchange_rates[pp.currency_id]
      end
    end

    tot
  end

  def self.get_most_important(currency_id, date, offset= 0,limit = 5)
    sql = "SELECT id, amount, currency_id, payment_date, ctype, transaction_id, "
    sql << create_currency_query(currency_id, date)
    sql << "FROM pay_plans WHERE organisation_id = ? "
    sql << "AND payment_date <= ? \n"
    sql << "ORDER BY amount_currency DESC\n"
    sql << "LIMIT #{offset}, #{5}"

    Organisation.find_by_sql([sql, OrganisationSession.organisation_id, date.to_date])
  end

  # Creates the query for exchanging the rate
  def self.create_currency_query(currency_id, date)
    @exchange_rates ||= CurrencyRate.current_hash

    sql = "CASE(currency_id)\n"
    get_currency_ids(date).each do |cur_id|
      sql << "WHEN #{cur_id} THEN amount * #{ @exchange_rates[cur_id] }\n"
    end
    sql << "ELSE amount\n"
    sql << "END AS amount_currency\n"
  end

  def self.get_currency_ids(date)
    pps = PayPlan.select("DISTINCT(currency_id) AS currency_id, amount, interests_penalties, payment_date, alert_date, email").org.unpaid.date(date).group("currency_id")
    pps.map(&:currency_id) 
  end

  # Returns the current state of the payment
  def state
    if paid?
      "Aplicado"
    elsif payment_date < Date.today
      "Atrasado"
    else
      "Válido"
    end
  end

  def repeat?
    repeat == "1" or repeat == "true" or repeat == true
  end

  # override the to_json
  def to_json
    self.attributes.merge(
      :transaction_payment_date => transaction_payment_date,
      :transaction_real_state => transaction_real_state,
      :transaction_cash => transaction_cash
    ).to_json
  end

  # method that describes the type of payment
  def pay_type
    case transaction_type
    when "Income" then "cobro"
    when "Buy", "Expense" then "pago"
    end
  end

private
  # checks if income or interests_penalties is filled
  def valid_income_or_interests_penalties_filled
    if amount <= 0 and interests_penalties <= 0
      errors.add(:amount, "Cantidad o Intereses/Penalidades debe ser mayor a 0")
    end
  end

  # checks that payment_date is greater or equal to alert_date
  def valid_payment_date_alert_date
    if alert_date > payment_date
      errors.add(:alert_date, "La fecha de alerta debe ser inferior o igual a la fecha de #{pay_type}")
    end
  end

  def set_defaults
    self.amount ||= self.transaction_pay_plans_balance
    self.interests_penalties ||= 0.0
    self.payment_date ||= Date.today
    self.alert_date ||= self.payment_date - 5.days
    self.currency_id ||= transaction_currency_id
    self.email = email.nil? ? false : email
  end

  def set_currency_id
    self.currency_id = self.transaction_currency_id
  end

  def get_transaction_cash
    if self.destroyed?
      PayPlan.unpaid.where(:transaction_id => transaction_id).size <= 0
    else
      false
    end
  end

  #############################3
  # Transaction methods

  # returns the payment_date for the transaction
  def get_transaction_payment_date
    pp = PayPlan.unpaid.where(:transaction_id => transaction_id)
    if pp.size > 0
      pp.order("payment_date ASC").limit(1).first.payment_date
    else
      nil
    end
  end

  #################

  # Checks that all pay_plans amounts sum <= transaction.total
  #def valid_pay_plans_total_amount
  #  pivot_amount = transaction_pay_plans_balance
  #  piv = transaction.pay_plans.pivot
  #  if piv
  #    pivot_amount = piv.amount
  #  end

  #  if amount > pivot_amount
  #    self.errors.add(:amount, "La cantidad que ingreso supera al total de la Nota de #{transaction.type_translated}")
  #  end
  #end

  # checks if the pay_plan has been paid
  def check_if_paid
    if paid?
      if transaction.class == "Income"
        text = "El plan de cobro ya fue cobrado"
      else
        text = "El plan de pago ya pue pagado"
      end
      self.errors.add(:base, text)
      text
    end
  end
end
