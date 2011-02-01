# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlan < ActiveRecord::Base
  acts_as_org
  after_initialize :set_defaults
  before_save :set_currency_id
  after_save :update_transaction
  #after_save :update_transaction_payment_date
  after_destroy :update_transaction

  STATES = ["valid", "delayed", "payed"]

  # relationships
  belongs_to :transaction

  # validations
  validate :valid_income_or_interests_penalties_filled
  validate :valid_pay_plans_total_amount
  validates_presence_of :payment_date, :alert_date

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

  # Returns the current state of the payment
  def state
    if paid?
      "Pagado"
    elsif payment_date < Date.today
      "Atrasado"
    else
      "Válido"
    end
  end

private
  # checks if income or interests_penalties is filled
  def valid_income_or_interests_penalties_filled
    if amount <= 0 and interests_penalties <= 0
      errors.add(:amount, "Cantidad o Intereses/Penalidades debe ser mayor a 0")
    end
  end

  def set_defaults
    self.amount ||= self.transaction.pay_plans_balance
    self.interests_penalties ||= 0.0
    self.payment_date ||= Date.today
    self.alert_date ||= self.payment_date
  end

  def set_currency_id
    self.currency_id = self.transaction.currency_id
  end

  def get_transaction_cash
    if self.destroyed?
      PayPlan.where(:transaction_id => transaction_id).size <= 0
    else
      false
    end
  end

  def get_transaction_payment_date
    pp = PayPlan.where(:transaction_id => transaction_id)
    if pp.size > 0
      pp.order("payment_date ASC").limit(1).first.payment_date
    else
      nil
    end
  end

  def update_transaction
    transaction.cash = get_transaction_cash
    transaction.payment_date = get_transaction_payment_date || Date.today#transaction.payment_date
    transaction.save
  end

  # Checks that all pay_plans amounts sum <= transaction.total
  def valid_pay_plans_total_amount
    minus = changes[:amount] ? changes[:amount].first.to_f : self.amount
    tot = transaction.pay_plans_total + amount - minus

    if tot > transaction.balance
      self.errors.add(:amount, "La cantidad que ingreso supera al total de la Nota de #{transaction.type_translated}")
    end
  end
end
