class Inventories::Errors < Struct.new(:inventory, :stocks)
  attr_reader :errors
  delegate :details, to: :inventory

  def set_errors
    @has_error = false
    @errors = {quantity: [], item_ids: []}
    stock_errors

    inventory.has_error = @has_error
    inventory.error_messages = get_errors
  end

  def stock_errors
    stocks.each do |stoc|
      if stoc.quantity < 0
        @errors[:quantity] << 'inventory.negative_stock' unless @has_error
        @has_error = true
        @errors[:item_ids] << stoc.item_id
      end
    end
  end

  def get_errors
    @has_error ? @errors : {}
  end
end
