# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::In < Inventories::Form

  def create
    save { inventory.save && update_stocks }
  end

private
  def operation
    'in'
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
