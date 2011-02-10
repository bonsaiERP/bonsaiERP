# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  acts_as_org

  TYPES = ['Income', 'Expense', 'Buy']
  # Determines if the oprations is made on transaction or pay_plan or payment
  attr_reader :trans
  # callbacks
  after_initialize :initialize_values, :if => :new_record?
  before_save :set_details_type
  before_save :calculate_total_and_set_balance, :if => :trans?
  after_create :update_payment_date

  # relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project

  has_many :pay_plans, :order => "payment_date ASC"
  has_many :payments
  has_many :transaction_details
  accepts_nested_attributes_for :transaction_details, :allow_destroy => true
  has_and_belongs_to_many :taxes, :class_name => 'Tax'

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id )


  # Transalates the type for any language
  def type_translated
    arr = case I18n.locale
      when :es
        ['Venta', 'Gasto', 'Compra']
    end
    Hash[TYPES.zip(arr)][type]
  end

  # quantity without discount and taxes
  def subtotal
    self.transaction_details.inject(0) {|sum, v| sum += v.total }
  end

  # Calculates the amount for taxes
  def total_taxes
    (gross_total - total_discount ) * tax_percent/100
  end

  def total_discount
    gross_total * discount/100
  end

  def total_payments
    payments.active.inject(0) {|sum, v| sum += v.amount }
  end

  def total_payments_with_interests
    payments.active.inject(0) {|sum, v| sum += v.amount + v.interests_penalties }
  end

  # Presents the currency symbol name if not default currency
  def present_currency
    unless Organisation.find(OrganisationSession.organisation_id).id == self.currency_id
      self.currency.to_s
    end
  end

  # Presents the total in currency unless the default currency
  def total_currency
    unless Organisation.find(OrganisationSession.organisation_id).id == self.currency_id
      self.total/self.currency_exchange_rate
    end
  end

  # Returns the total value of pay plans
  def pay_plans_total
    pay_plans.unpaid.inject(0) {|sum, v| sum += v.amount }
  end

  # Returns the total amount to be paid
  def pay_plans_balance
    sum = pay_plans.inject(0) {|sum, v| sum += v.amount unless v.paid? ; sum}
    balance - sum
  end

  # Updates cash based on the pay_plans
  def update_pay_plans_cash
    self.cash = ( pay_plans.size > 0 )
    self.save
  end

  # Sets a default payment date
  def update_payment_date
    if pay_plans.size > 0
      self.payment_date = self.pay_plans.map(&:payment_date).sort.first
    else
      self.payment_date = self.date
    end
  end

  # Prepares a payment with the current notes to pay
  # @param Hash options
  def new_payment(options = {})
    if cash?
      Payment.new({:amount => balance, :transaction_id => id}.merge(options))
    else
      pp = pay_plans.where(:paid => false).order("payment_date ASC").limit(1).first
      if pp
        Payment.new({:amount => pp.amount, :interests_penalties => pp.interests_penalties,
                  :transaction_id => id}.merge(options))
      else
        Payment.new({:transaction_id => id, :amount => balance}.merge(options))
      end
    end
  end

  # Adds a payment and updates the balance
  def add_payment(amount)
    if amount > balance
      return false
    else
      @trans = false
      self.balance = (balance - amount)
      self.save
    end
  end

  # Substract the amount from the balance
  def substract_payment(amount)
    @trans = false
    self.balance = (balance + amount)
    self.state = 'aproved'
    self.save
  end

  def set_trans(value)
    @trans = value
  end

private
  # set default values for discount and taxes
  def initialize_values
    @trans = true
    self.cash = cash.nil? ? true : cash
    self.active = active.nil? ? true : active
    self.discount ||= 0
    self.tax_percent = taxes.inject(0) {|sum, t| sum += t.rate }
    self.gross_total ||= 0
  end

  # Sets the type of the class making the transaction
  def set_details_type
    self.transaction_details.each{ |v| v.ctype = self.class.to_s }
  end

  # Calculates the total value and stores it
  def calculate_total_and_set_balance
    self.gross_total = transaction_details.select{|t| !t.marked_for_destruction? }.inject(0) {|sum, det| sum += det.total }
    self.total = self.balance = gross_total - total_discount + total_taxes
  end

  # Determines if it is a transaction or other operation
  def trans?
    @trans
  end
end
