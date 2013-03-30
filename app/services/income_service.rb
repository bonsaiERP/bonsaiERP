# encoding: utf-8
class IncomeService < TransactionService

  attr_reader :income, :ledger

  validate :valid_account_to, if: :direct?

  delegate :contact, :is_approved?, :income_details, 
    :income_details_attributes, :income_details_attributes=,
    :subtotal, :total, :to_s, :state, :discount, to: :income

  # Creates and instance of income and initializes
  def initialize(attrs = {})
    @income = Income.new_income income_params(attrs)
    super attrs
  end

  # Finds the income and sets data with the income found
  def self.find(id)
    @income = Income.find(id)
    res = new(@income.attributes)
    res.income = @income
    res
  end

  # Creates and can call other methods passed in the block
  def create
    build_ledger if can_pay?
    set_income_data
    yield if block_given?

    create_or_update do
      res = income.save
      create_ledger && res
    end
  end

  # Creates  and approves an Income
  def create_and_approve
    create { income.approve! }
  end

  def update(params = {})
    build_ledger if can_pay?
    create_or_update do
      res = TransactionHistory.new.create_history(income)
      income.attributes = params

      yield if block_given?
      update_income_data

      res = income.save

      create_ledger && res
    end
  end

  def update_and_approve(params)
    update(params) { income.approve! }
  end

private
  # Creates or updates and sets errors messages in case of failing
  def create_or_update(&b)
    res = valid?
    res = commit_or_rollback { b.call } && res

    set_errors(income) unless res

    res
  end

  def income_params(attrs)
    attrs[:ref_number] = Income.get_ref_number unless attrs[:ref_number].present?
    attrs[:date] = Date.today unless attrs[:date].present?
    attrs[:currency] = OrganisationSession.currency unless attrs[:currency].present?
    attrs.except(:direct, :account_to_id, :income_details_attributes)
  end

  # Updates the data for an imcome
  # total is the alias for amount due that Income < Account
  def update_income_data
    income.balance -= (income.total_was - income.total)
    income.set_state_by_balance!
    update_details
    IncomeErrors.new(income).set_errors
  end

  def set_income_data
    set_new_details
    income.ref_number = Income.get_ref_number
    income.gross_total = original_income_total
    income.balance = income.total
    income.state = 'draft' if state.blank?
    income.discounted = true if discount > 0
    income.creator_id = UserSession.id

    if direct?
      income.state = 'paid'
      income.amount = 0.0
    end
  end

  # Set details for a new Income
  def set_new_details
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance = get_detail_balance(det)
    end
  end

  def update_details
    income_details.each do |det|
      det.balance = get_detail_balance(det)
    end
  end

  def get_detail_balance(det)
    det.balance - (det.quantity_was - det.quantity)
  end

  def set_details_original_prices
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def original_income_total
    income_details.inject(0) do |sum, det|
      sum += det.quantity.to_f * det.original_price.to_f
    end
  end

  def item_ids
    @item_ids ||= income_details.map(&:item_id)
  end

  # Creates a ledger if it can pay
  def build_ledger
    @ledger = AccountLedger.new(
      account_to_id: account_to_id,
      operation: 'payin', exchange_rate: 1,
      currency: income.currency, inverse: false
    )
  end

  # Saves the ledger with income data
  def create_ledger
    return true unless ledger.present?
    ledger.account_id = income.id
    ledger.amount = income.total

    ledger.save_ledger
  end

  def can_pay?
    income.is_draft? && direct?
  end

  def valid_account_to
    unless account_to.present?
      self.errors.add :account_to_id, I18n.t('errors.messages.quick_income.valid_account_to')
    end
  end

  def direct?
    direct == true
  end

  def account_to
    @account_to ||= AccountQuery.new.bank_cash.where(currency: currency, id: account_to_id).first
  end
end
