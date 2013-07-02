# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::Form < Movements::Form
  alias :income :movement

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :income_details,
           :subtotal, :to_s, :state, :discount, :details,
           :income_details_attributes, :income_details_attributes=,
           to: :income

  delegate :id, to: :income, prefix: true

  # Creates and instance of income and initializes
  def self.new_income(attrs = {})
    _object = new(attrs.slice(*ATTRIBUTES))
    _object.set_new_income(attrs)
    _object
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    _object = new
    _object.set_service_attributes(Income.find(id))
    _object
  end

  # Creates  and approves an Income
  def create_and_approve
    @movement.approve!

    create
  end

  def update_and_approve(attrs = {})
    @movement.approve!

    update attrs
  end

  def set_new_income(attrs = {})
    @movement = Income.new_income
    MovementService.new(@movement).set_new(attrs)
    copy_new_defaults
  end

private
  def build_ledger
    @ledger = AccountLedger.new(
      account_id: income.id, amount: income.total,
      account_to_id: account_to_id, date: date,
      operation: 'payin', exchange_rate: 1,
      currency: income.currency, inverse: false,
      reference: get_reference
    )
  end

  def get_reference
    reference.present? ? reference : I18n.t('income.payment.reference', income: income)
  end

  def income_is_valid
    self.errors.add :base, I18n.t('errors.messages.income.payments') unless income.total === income.balance
  end

  def valid_account_to
    self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end
end
