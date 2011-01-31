# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  acts_as_org

  TYPES = ['Income', 'Expense', 'Buy']
  # callbacks
  after_initialize :initialize_values
  before_create :set_payment_date
  before_save :set_details_type
  before_save :calculate_total_and_set_balance

  # relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project

  has_many :pay_plans
  has_many :transaction_details
  accepts_nested_attributes_for :transaction_details
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
    pay_plans.inject(0) {|sum, v| sum += v.amount }
  end

  # Returns the total amount to be paid
  def pay_plans_balance
    sum = pay_plans.inject(0) {|sum, v| sum += v.amount unless v.paid? ; sum}
    balance - sum
  end

private
  # set default values for discount and taxes
  def initialize_values
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
    self.gross_total = transaction_details.inject(0) {|sum, det| sum += det.total }
    self.total = self.balance = gross_total - total_discount + total_taxes
  end

  # Sets a default payment date
  def set_payment_date
    self.payment_date = self.date
  end
end
