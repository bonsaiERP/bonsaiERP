# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that helps manage details for Inventory
class Inventories::Details < Struct.new(:inventory)
  delegate :details, :store_id, :store_to_id, to: :inventory

  def item_ids
    #@item_ids ||= details.select{|v| v.quantity > 0 }.map(&:item_id).uniq
    @item_ids ||= details.map(&:item_id).uniq
  end

  def stocks
    @stocks ||= item_ids.map {|v| set_stock(v) }
  end

  def stocks=(new_stocks)
    @stocks = new_stocks
  end

  def stocks_to
    @stocks_to ||= item_ids.map {|v| set_stock_to(v)}
  end

  def set_stock(item_id)
    if st = item_stocks.find {|v| v.item_id === item_id }
      st
    else
      NullStock.new(minimum: 0, quantity: 0, item_id: item_id)
    end
  end

  def set_stock_to(item_id)
    if st = item_stocks_to.find {|v| v.item_id === item_id }
      st
    else
      NullStock.new(minimum: 0, quantity: 0, item_id: item_id)
    end
  end

  def detail(item_id)
    details.find {|v| v.item_id === item_id}
  end

  # Receives a stock and calculates quantity for an item
  def item_quantity(item_id)
    details.select {|v| v.item_id === item_id}.inject(0) {|s, v| s += v.quantity }
  end

  # returns the stock for an item_id in the list
  def stock(item_id)
    stocks.find {|st| st.item_id === item_id }
  end

  def item_stocks
    @item_stocks ||= Stock.active.store_house(store_id).where(item_id: item_ids).to_a
  end

  def item_stocks_to
    @item_stocks_to ||= Stock.active.store_house(store_to_id).where(item_id: item_ids).to_a
  end
end

class NullStock < OpenStruct
  def update_attribute(k, val)
    true
  end
end
