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

  def get_ref_number
    InventoryOperation.get_ref_number('Ing')
  end
private
  def get_operation
    'invin'
  end

  def update_stocks
    res = true
    stocks.each do |st|
      stoc = Stock.create(store_id: store_id, item_id: st.item_id, quantity: stock_quantity(st) )
      res = stoc.save && st.update_attribute(:active, false)

      return false unless res
    end

    res
  end

  def stock_quantity(st)
    st.quantity + item_quantity(st.item_id)
  end
end
