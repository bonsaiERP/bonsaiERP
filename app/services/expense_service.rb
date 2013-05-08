# encoding: utf-8
class ExpenseService < TransactionService
  attr_accessor :expense

  validate :expense_is_valid,  if: :direct_payment?
  validate :valid_account_to, if: :direct_payment?

  delegate :contact, :is_approved?, :is_draft?, :expense_details,
    :expense_details_attributes, :expense_details_attributes=,
    :expense_details,
    :subtotal, :to_s, :state, :discount, to: :expense

  delegate :id, to: :expense, prefix: true

  def self.new_expense(attrs = {})
    attrs = set_new_expense_attributes(attrs)
    es = new(attrs) do |e|
      e.expense = Expense.new_expense(attrs.except(:direct_payment, :account_to_id, :expense_details_attributes, :reference))
    end
    es.expense_details.build(quantity: 1) if es.expense_details.empty?

    es
  end

  # Finds the expense and sets data with the expense found
  def self.find(id)
    exp = Expense.find(id)
    new(exp.attributes) do |es|
      es.ref_number = exp.ref_number
      es.total = exp.total
      es.due_date = exp.due_date
      es.expense = exp
    end
  end

  # Creates and can call other methods passed in the block
  def create
    set_expense_data
    create_or_update { expense.save }
  end

  # Creates  and approves an Expense
  def create_and_approve
    set_expense_data

    create_or_update do
      expense.approve!
      expense.amount = 0 if direct_payment?

      expense.set_state_by_balance!
      res = expense.save
      res = res && create_ledger if direct_payment?

      res
    end
  end

  def update(attrs = {})
    self.attributes = attrs

    create_or_update do
      res = TransactionHistory.new.create_history(expense)
      expense.attributes = expense_attributes
      update_expense_data

      expense.save && res
    end
  end

  def update_and_approve(attrs = {})
    self.attributes = attrs

    create_or_update do
      expense.approve!
      res = TransactionHistory.new.create_history(expense)
      expense.attributes = expense_attributes

      update_expense_data
      expense.amount = 0 if direct_payment?
      expense.set_state_by_balance!

      res = expense.save && res

      res = res && create_ledger if direct_payment?

      res
    end
  end

  # Sets the expense params when new_record
  def self.set_new_expense_attributes(attrs)
    attrs[:ref_number] = Expense.get_ref_number if attrs[:ref_number].blank?
    attrs[:date] = Date.today if attrs[:date].blank?
    attrs[:currency] = OrganisationSession.currency if attrs[:currency].blank?
    attrs
  end

private
  # Creates or updates and sets errors messages in case of failing
  def create_or_update(&b)
    res = valid?
    res = commit_or_rollback { b.call } && res if res

    set_errors(*[expense, ledger].compact) unless res

    res
  end

  def expense_attributes
    attributes.except(:direct_payment, :account_to_id, :expense_details_attributes, :reference)
  end

  # Updates the data for an imcome
  # total is the alias for amount due that Expense < Account
  def update_expense_data
    set_expense_details
    expense.balance -= (expense.total_was - expense.total)
    expense.gross_total = original_expense_total
    expense.set_state_by_balance!
    expense.discounted = ( expense.discount > 0 )

    ExpenseErrors.new(expense).set_errors
  end

  def set_expense_data
    set_expense_details

    expense.ref_number = Expense.get_ref_number if expense.new_record?
    expense.gross_total = original_expense_total
    expense.amount = expense.total
    expense.state = 'draft' if state.blank?
    expense.discounted = ( expense.discount > 0 )
    expense.creator_id = UserSession.id
  end

  def set_paid_expense
    expense.balance = 0
    expense.state = 'paid'
  end

  # Set details for a new Expense
  def set_expense_details
    expense_details.each do |det|
      det.original_price = item_prices[det.item_id]
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

  # Saves the ledger with expense data
  def create_ledger
    @ledger = AccountLedger.new(
      account_id: expense.id, amount: - expense.total,
      account_to_id: account_to_id, date: date,
      operation: 'payout', exchange_rate: 1,
      currency: expense.currency, inverse: false,
      reference: get_reference
    )

    @ledger.save_ledger
  end

  def get_reference
    reference.present? ? reference : I18n.t('expense.payment.reference', expense: expense)
  end

  def expense_is_valid
    self.errors.add :base, I18n.t('errors.messages.expense.not_draft') unless expense.is_draft?
  end

  def valid_account_to
    unless account_to.present?
      self.errors.add :account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')
    end
  end

  def direct_payment?
    direct_payment === true
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :buy_price)]
  end
end
