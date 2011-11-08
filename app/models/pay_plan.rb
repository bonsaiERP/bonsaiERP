# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlan < ActiveRecord::Base
  after_initialize :set_defaults
  before_create    :set_operation
  before_save      :set_currency_id
  #before_save      :set_ctype,      :if => 'ctype.blank?'
  before_destroy   :check_if_paid
  #after_save :update_transaction
  #after_save :update_transaction_payment_date
  #after_destroy :update_transaction
  
  # repeat repeats the pay_plan over until it fills the balance of a transaction
  attr_accessor :repeat, :destroy_in_list
  attr_protected :destroy_in_list#, :transaction_id

  STATES = ["valid", "delayed", "applied"]

  # relationships
  belongs_to :transaction
  belongs_to :currency

  # delegations
  delegate :currency_id, :payment_date, :real_state, :paid?, :cash, :ref_number, :draft?, :balance, :state, :type,
    :to => :transaction, :prefix => true
  delegate :name, :symbol, :to => :currency, :prefix => true, :allow_nil => true

  # validations
  #validate :valid_income_or_interests_penalties_filled
  validates_presence_of :payment_date, :alert_date
  validates_numericality_of :amount, :greater_than => 0
  validate :valid_payment_date_alert_date

  # scopes
  scope :unpaid, where(:paid => false)
  scope :paid,   where(:paid => true)
  scope :date,   lambda {|d| where(["payment_date <= ?", d]) }
  scope :in,     where(:ctype => "Income")
  scope :out,    where(:ctype => ["Buy", "Expense"])


  attr_accessible :payment_date, :alert_date, :amount, :email, :repeat

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

  def self.get_most_important(currency_id, date, types, offset= 0,limit = 5)
    return [] if PayPlan.org.empty?

    sql = "SELECT id, amount, currency_id, payment_date, ctype, transaction_id, "
    sql << create_currency_query(currency_id, date)
    sql << "FROM pay_plans WHERE organisation_id = ? AND paid = ? "
    sql << "AND payment_date <= ? \n"
    sql << "AND ctype IN (?) \n"
    sql << "ORDER BY amount_currency DESC\n"
    sql << "LIMIT #{offset}, #{limit}"

    Organisation.find_by_sql([sql, OrganisationSession.organisation_id, false, date.to_date, types])
  end

  # Creates the query for exchanging the rate
  def self.create_currency_query(currency_id, date)
    @exchange_rates ||= CurrencyRate.current_hash
    sql = "CASE(currency_id)\n"
    get_currency_ids(date).each do |cur_id|
      sql << "WHEN #{cur_id} THEN amount * #{ @exchange_rates[cur_id] }\n" unless currency_id == cur_id
    end
    sql << "ELSE amount\n"
    sql << "END AS amount_currency\n"
  end

  def self.get_currency_ids(date)
    pps = PayPlan.select("DISTINCT(currency_id) AS currency_id, amount, payment_date, alert_date, email").org.unpaid.date(date).group("currency_id")
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
    if amount <= 0
      errors.add(:amount, I18n.t("errors.messages.pay_plan.valid_amount_and_interests") )
    end
  end

  # checks that payment_date is greater or equal to alert_date
  def valid_payment_date_alert_date
    if alert_date > payment_date
      errors.add(:alert_date, I18n.t("errors.messages.pay_plan.valid_date", :pay_type => pay_type))
    end
  end

  def set_defaults
    self.amount ||= self.transaction_pay_plans_balance
    self.payment_date ||= Date.today
    self.alert_date ||= self.payment_date - 5.days
    self.currency_id ||= transaction_currency_id
    self.email = email.nil? ? true : email
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

  #def set_ctype
  #  ctype = transaction.class.to_s
  #end

  def set_operation
    if transaction.is_a?(Income)
      self.operation = 'in'
    else
      self.operation = 'out'
    end
  end
end
