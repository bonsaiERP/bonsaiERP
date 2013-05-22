# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Form < BaseForm
  attribute :store_id, Integer
  attribute :date, Date
  attribute :ref_number, String
  attribute :description, String
  attribute :inventory_details_attributes, Array

  attr_writer :inventory

  delegate :inventory_details, :details,
           :inventory_details_attributes=,
           to: :inventory

  validates_presence_of :store

  def store
    @store ||= Store.active.where(id: store_id).first
  end

  def inventory
    @inventory ||= Inventory.new(
      store_id: store_id, date: date, description: description,
      inventory_details_attributes: inventory_details_attributes
    )
  end

private
  def item_ids
    @item_ids ||= items.map(&:item_id).uniq
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

  def item_stocks
    @item_stocks ||= Stock.active.store(store_id).where(item_id: item_ids).to_a
  end

  def details
    @details ||= inventory_details.select {|v| v.quantity > 0 }
  end

  # Receives a stock and calculates quantity for an item
  def item_quantity(item_id)
    items.select {|v| v.item_id === item_id}.inject(0) {|s, v| s += v.quantity }
  end

  def self.public_attributes
    [:store_id, :date, :description]
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
