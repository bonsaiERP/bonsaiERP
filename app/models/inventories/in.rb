# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::In < Inventories::Form

  def create
    save { update_stocks && inventory.save }
  end

private
  def operation
    'in'
  end

  def update_stocks
    res = true
    stocks.each do |st|
      stock = Stock.new(store_id: store_id, item_id: st.item_id, quantity: stock_quantity(st) )

      res = stock.save && st.update_attribute(:active, false)

      return false unless res
    end

    res
  end

  def stock_quantity(st)
    st.quantity + item_quantity(st.item_id)
  end
end
