# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryIncomeIn < InventoryOperationService

  def deliver
    res = true
    commit_or_rollback do
      res = set_inventory_operation({ref_number}).save
      res = res && update_stocks {|st| st.quantity - item_quantity(st.item_id)}
      res = res && update_income_details
    end

    set_errors(inventory_operation) unless res

    res
  end

  def devolution
    res = true
    commit_or_rollback do
      res = inventory_operation.save
      res = res && update_stocks {|st| st.quantity + item_quantity(st.item_id)}
      res = res && update_income_details
    end

    set_errors(inventory_operation) unless res

    res
  end

private

  def update_stocks
    res = true
    stocks.each do |st|
      stoc = Stock.create(store_id: store_id, item_id: st.item_id, quantity: yield(st) )
      res = stoc.save && st.update_attribute(:active, false)

      return false unless res
    end

    res
  end

  def stock_quantity(st)
    st.quantity + item_quantity(st.item_id)
  end
end
