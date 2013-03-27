# encoding: utf-8
class IncomeService < DefaultTransaction
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
  attribute :direct, Boolean
  attribute :account_to_id, Integer

  attr_accessor :income

  delegate :contact, :is_approved?, :income_details, 
    :income_details_attributes, :income_details_attributes=,
    :subtotal, :total, :to_s, :state, :discount, to: :income

  # Creates and instance of income and initializes
  def initialize(attrs = {})
    attrs = income_params(attrs)
    @income = Income.new_income attrs.except(:income_details_attributes)
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
    set_income_data
    yield if block_given?

    income.save
  end

  # Creates  and approves an Income
  def create_and_approve
    create { income.approve! }
  end

  def update(params = {})
    commit_or_rollback do
      res = TransactionHistory.new.create_history(income)
      income.attributes = params

      yield if block_given?

      update_income_data

      income.save && res
    end
  end

  def update_and_approve(params)
    update(params) { income.approve! }
  end

private
  def income_params(attrs)
    attrs[:ref_number] = Income.get_ref_number unless attrs[:ref_number].present?
    attrs[:date] = Date.today unless attrs[:date].present?
    attrs[:currency] = OrganisationSession.currency unless attrs[:currency].present?
    attrs
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
end
