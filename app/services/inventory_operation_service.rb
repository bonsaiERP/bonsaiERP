# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperationService < BaseService
  attribute :store_id, Integer
  attribute :date, Date
  attribute :description, String
  attribute :inventory_operation_details_attributes, Array

  attr_writer :inventory_operation

  delegate :inventory_operation_details,
           :inventory_operation_details_attributes=,
           to: :inventory_operation

  validates_presence_of :store
  validate :unique_item_ids

  def store
    @store ||= Store.where(id: store_id).first
  end

  def inventory_operation
    @inventory_operation ||= InventoryOperation.new(
      store_id: store_id, date: date, description: description,
      operation: get_operation, ref_number: get_ref_number,
      inventory_operation_details_attributes: inventory_operation_details_attributes
    )
  end

private
  def item_ids
    @item_ids ||= inventory_operation_details.map(&:item_id).uniq
  end

  def stock_hash
    Hash[stocks.map {|v| [v.id, v]}]
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
    @details ||= inventory_operation_details.select {|v| v.quantity > 0 }
  end

  def item_quantity(item_id)
    items.select {|v| v.item_id === item_id}.inject(0) {|s, v| s += v.quantity }
  end

  def self.public_attributes
    [:store_id, :date, :description]
  end

  # Null methods that will be created in other clases
  [:get_operation, :get_ref_number].each do |met|
    define_method met do
    end
  end
end

class NullStock < OpenStruct
  def update_attribute(k, val)
    true
  end
end
