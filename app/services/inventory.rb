# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventory < InventoryOperationService

  def save_in
    res = true
    commit_or_rollback do
      inventory_operation.ref_number = InventoryOperation.get_ref_number('Ing')
      inventory_operation.operation = 'in'

      res = inventory_operation.save
      res = res && update_stocks {|st| st.quantity + item_quantity(st.item_id)}
    end

    set_errors(inventory_operation) unless res

    res
  end

  def save_out
    res = true
    commit_or_rollback do
      inventory_operation.ref_number = InventoryOperation.get_ref_number('Egr')
      inventory_operation.operation = 'out'

      res = inventory_operation.save
      res = res && update_stocks {|st| st.quantity - item_quantity(st.item_id)}
    end

    set_errors(inventory_operation) unless res

    res
  end
end
