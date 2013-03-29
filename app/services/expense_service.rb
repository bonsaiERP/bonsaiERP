# encoding: utf-8
class ExpenseService < DefaultTransaction
  attribute :id, Integer
  attribute :ref_number, String
  attribute :date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :exchange_rate, Decimal
  attribute :project_id, Integer
  attribute :bill_number, String
  attribute :due_date, Date
  attribute :description, String
  attribute :direct_payment, Boolean
  attribute :account_to_id, Integer

  attr_accessor :expense, :ledger

  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :expense_details, 
    :expense_details_attributes, :expense_details_attributes=,
    :subtotal, :total, :to_s, :state, :discount, to: :expense

  delegate :id, to: :expense, prefix: true

  # Creates and instance of expense and initializes
  def initialize(attrs = {})
    @expense = Expense.new_expense expense_params(attrs)
    super attrs
    @expense.expense_details.build(quantity: 1) if @expense.expense_details.empty?
  end

  # Finds the expense and sets data with the expense found
  def self.find(id)
    @expense = Expense.find(id)
    res = new(@expense.attributes)
    res.expense = @expense
    res
  end

  # Creates and can call other methods passed in the block
  def create
    build_ledger if can_pay?
    set_expense_data
    yield if block_given?

    create_or_update do
      res = expense.save
      res && create_ledger
    end
  end

  # Creates  and approves an Expense
  def create_and_approve
    create { expense.approve! }
  end

  def update(params = {})
    build_ledger if can_pay?
    create_or_update do
      res = TransactionHistory.new.create_history(expense)
      expense.attributes = params

      yield if block_given?
      update_expense_data

      res = expense.save

      create_ledger && res
    end
  end

  def update_and_approve(params)
    update(params) { expense.approve! }
  end

private
  # Creates or updates and sets errors messages in case of failing
  def create_or_update(&b)
    res = valid?
    res = commit_or_rollback { b.call } && res

    set_errors(expense) unless res

    res
  end

  def expense_params(attrs)
    attrs[:ref_number] = Expense.get_ref_number unless attrs[:ref_number].present?
    attrs[:date] = Date.today unless attrs[:date].present?
    attrs[:currency] = OrganisationSession.currency unless attrs[:currency].present?
    attrs.except(:direct_payment, :account_to_id, :expense_details_attributes)
  end

  # Updates the data for an imcome
  # total is the alias for amount due that Expense < Account
  def update_expense_data
    expense.balance -= (expense.total_was - expense.total)
    expense.set_state_by_balance!
    update_details
    ExpenseErrors.new(expense).set_errors
  end

  def set_expense_data
    set_new_details
    expense.ref_number = Expense.get_ref_number
    expense.gross_total = original_expense_total
    expense.balance = expense.total
    expense.state = 'draft' if state.blank?
    expense.discounted = true if discount > 0
    expense.creator_id = UserSession.id

    if direct_payment?
      expense.state = 'paid'
      expense.amount = 0.0
    end
  end

  # Set details for a new Expense
  def set_new_details
    expense_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance = get_detail_balance(det)
    end
  end

  def update_details
    expense_details.each do |det|
      det.balance = get_detail_balance(det)
    end
  end

  def get_detail_balance(det)
    det.balance - (det.quantity_was - det.quantity)
  end

  def set_details_original_prices
    expense_details.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def original_expense_total
    expense_details.inject(0) do |sum, det|
      sum += det.quantity.to_f * det.original_price.to_f
    end
  end

  def item_ids
    @item_ids ||= expense_details.map(&:item_id)
  end

  # Creates a ledger if it can pay
  def build_ledger
    @ledger = AccountLedger.new(
      account_to_id: account_to_id,
      operation: 'payin', exchange_rate: 1,
      currency: expense.currency, inverse: false
    )
  end

  # Saves the ledger with expense data
  def create_ledger
    return true unless ledger.present?
    ledger.account_id = expense.id
    ledger.amount = -expense.total

    ledger.save_ledger
  end

  def can_pay?
    expense.is_draft? && direct_payment?
  end

  def valid_account_to
    unless account_to.present?
      self.errors.add :account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')
    end
  end

  def direct_payment?
    direct_payment == true
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end
end

