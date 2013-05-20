# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpenseService < TransactionService
  alias :expense :transaction

  validate :income_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :income_details,
           :subtotal, :to_s, :state, :discount, :items,
           :income_details_attributes, :income_details_attributes=,
           to: :expense

  delegate :id, to: :income, prefix:true

  # Creates and instance of income and initializes
  def self.new_expense(attrs = {})
    is = new(attrs.slice(*ATTRIBUTES))
    is.set_new_expense(attrs)
    is
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    is = new
    is.set_service_attributes(Expense.find(id))
    is
  end

  # Creates  and approves an Income
  def create_and_approve
    @transaction.approve!

    create
  end

  def update_and_approve(attrs = {})
    @transaction.approve!

    update attrs
  end

  def set_new_expense(attrs = {})
    @transaction = Expense.new_expense
    IncomeExpenseService.new(@transaction).set_new(attrs)
  end

private
  def build_ledger
    @ledger = AccountLedger.new(
      account_id: expense.id, amount: -expense.total,
      account_to_id: account_to_id, date: date,
      operation: 'payout', exchange_rate: 1,
      currency: expense.currency, inverse: false,
      reference: get_reference
    )
  end

  def get_reference
    reference.present? ? reference : I18n.t('expense.payment.reference', expense: expense)
  end

  def income_is_valid
    self.errors.add :base, I18n.t('errors.messages.expense.payments') unless expense.total === expense.balance
  end

  def valid_account_to
    self.errors.add(:account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')) unless account_to.present?
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end
end
