# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperationDetail < ActiveRecord::Base
  acts_as_org

  belongs_to :inventory_operation
  belongs_to :item

  validates_presence_of :item_id, :quantity
  validates_numericality_of :quantity, :greater_than => 0
  validate :valid_quantity_for_transaction

private
  # Validtes the quantiry for a transaction
  def valid_quantity_for_transaction
    #if inventory_operation.transaction_id.present?
    #  it = inventory_operation.transaction.transaction_details.find_by_item_id(item_id)

    #  if quantity > it.balance
    #    det.errors.add(:quantity, "Cantidad mayor a la permitida")
    #  end
    #end
  end
end
