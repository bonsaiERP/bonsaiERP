# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperationService < BaseService
  attribute :store_id, Integer
  attribute :date, Date
  attribute :description, String

  delegate :inventory_operation_details, to: :inventory_operation

  validates_presence_of :store

  def store
    @store ||= Store.where(id: store_id).first
  end

  def inventory_operation
    @inventory_operation ||= InventoryOperation.new(
      store_id: store_id, date: date, description: description,
      operation: get_operation
    )
  end

private
  def item_ids
    @item_ids ||= inventory_operation_details.map(&:item_id)
  end

  def stock_hash
    Hash[stocks.map {|v| [v.id, v]}]
  end

  def stocks
    @stocks ||= Stock.active.store(store_id)
  end

  def details
    @details ||= inventory_operation_details.select {|v| v.quantity > 0 }
  end

  def get_operation
  end
end
