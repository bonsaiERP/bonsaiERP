# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that helps manage details for Inventory
class Inventories::Details < Struct.new(:inventory)
  delegate :details, :store_id, to: :inventory

  def item_ids
    @item_ids ||= details.select{|v| v.quantity > 0 }.map(&:item_id).uniq
  end

  def stocks
    @stocks ||= item_ids.map {|v| set_stock(v) }
  end

  def set_stock(item_id)
    if st = item_stocks.find {|v| v.item_id === item_id }
      st
    else
      NullStock.new(minimum: 0, quantity: 0, item_id: item_id)
    end
  end

  # Receives a stock and calculates quantity for an item
  def item_quantity(item_id)
    details.select {|v| v.item_id === item_id}.inject(0) {|s, v| s += v.quantity }
  end

  def item_stocks
    @item_stocks ||= Stock.active.store(store_id).where(item_id: item_ids).to_a
  end

  # Updates the stocks using a block for updating the stock quantity
  def update_stocks(&stock_quantity_block)
    res = true
    stocks.each do |st|
      stoc = Stock.create(store_id: store_id, item_id: st.item_id, quantity: stock_quantity_block.call(st) )
      res = stoc.save && st.update_attribute(:active, false)

      return false unless res
    end

    res
  end
end

class NullStock < OpenStruct
  def update_attribute(k, val)
    true
  end
end
