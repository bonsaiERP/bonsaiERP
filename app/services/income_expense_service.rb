# Sets and Income or expense
class IncomeExpenseService
  attr_reader :trans_errors, :trans_klass, :transaction
  ATTRIBUTES = [:date, :contact_id, :total, :exchange_rate, :project_id, :due_date, :description].freeze

  delegate :items, :discount, :total, :original_total, to: :transaction

  def initialize(trans)
    @transaction = trans
    if @transaction.is_a?(Income)
      set_income
    else
      set_expense
    end
  end

  def set_new(attrs = {})
    @transaction.attributes = attrs.slice(*attributes).merge(
      ref_number: @trans_klass.get_ref_number,
      date: attrs[:date] || Date.today,
      state: 'draft',
      creator_id: UserSession.id,
      currency: attrs[:currency] || OrganisationSession.currency
    )

    set_details
    @transaction.gross_total = original_total
    @transaction.discounted = (discount > 0)
    @transaction.balance = total

    @transaction.items.build if @transaction.items.empty?
  end

  # Updates the data for an imcome or expense
  # balance is the alias for amount due that Income < Account
  def set_update(attrs = {})
    set_details
    @transaction.attributes = attrs.slice(*attributes_for_update)
    @transaction.balance    -= (@transaction.total_was - @transaction.total)
    @transaction.gross_total = original_total
    @transaction.set_state_by_balance!
    @transaction.discounted  = ( discount > 0 )

    @trans_errors.new(transaction).set_errors
  end

private
  def set_income
    @trans_klass   = Income
    @trans_errors  = IncomeErrors
    @trans_details = :income_details_attributes
  end

  def set_expense
    @trans_klass   = Expense
    @trans_errors  = ExpenseErrors
    @trans_details = :expense_details_attributes
  end

  def attributes
    ATTRIBUTES + [@trans_details]
  end

  def attributes_for_update
    attributes.reject {|v| v === :contact_id}
  end

  # Set details for a new Income or Expense
  def set_details
    items.each do |det|
      det.price          = det.price || 0
      det.quantity       = det.quantity || 0
      det.original_price = item_prices[det.item_id]
      det.balance        = get_detail_balance(det)
    end
  end

  def get_detail_balance(det)
    det.balance - (det.quantity_was - det.quantity)
  end

  def original_total
    items.inject(0) {|sum, det| sum += det.quantity.to_f * det.original_price.to_f }.to_d
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :buy_price)]
  end

  def set_details_original_prices
    items.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def item_ids
    @item_ids ||= items.map(&:item_id)
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end
end
