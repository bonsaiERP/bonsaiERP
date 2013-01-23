# encoding: utf-8
class DefaultExpense < DefaultTransaction
  attr_reader :expense

  delegate :state, :expense_details, :discount, to: :expense

  def initialize(inc)
    raise 'Must be a Expense class' unless inc.is_a?(Expense)
    @transaction = @expense = inc
  end

  def create
    set_expense_data
    yield if given_block?
    expense.save
  end

  def create_and_approve
    create { expense.approve! }
  end

  def update(params)
    expense.attributes = params

    expense.save
  end

private
  def set_expense_data
    set_new_details
    expense.ref_number = Expense.get_ref_number
    expense.gross_total = original_expense_total
    expense.balance = expense.total
    expense.state = 'draft' if state.blank?
    expense.discounted = true if discount > 0
    expense.creator_id = UserSession.id
  end

  def set_new_details
    expense_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance = det.quantity
    end
  end

  def set_details_balance
    expense_details.each {|det| det.balance = det.quantity }
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
    expense_details.map(&:item_id)
  end
end
