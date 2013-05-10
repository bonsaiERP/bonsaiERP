# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryIn < InventoryOperationService

  def create
    res = true
    commit_or_rollback do
      res = inventory_operation.save && update_stocks
    end

    set_errors(inventory_operation) unless res

    res
  end

  def self.find(id, attrs)
    inv = new(attrs.slice(*public_attributes))
    inv.inventory_operation = InventoryOperation.find(id)
    inv.inventory_operation_details_attributes = attrs[:inventory_operation_details_attributes]
    inv
  end

private
  def get_operation
    'invin'
  end

  def update_stocks
    res = true
    stocks.each do |st|
      res = Stock.create(store_id: store_id)
      st.update_attribute()
      return false unless res
    end
  end

  def get_ref_number
    InventoryOperation.get_ref_number('Ing')
  end
end
