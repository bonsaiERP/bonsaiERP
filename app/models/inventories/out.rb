# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Out < Inventories::Form

  def create
    save { update_stocks && inventory.save }
  end

private
  def operation
    'out'
  end

  def update_stocks
    res = true

    stocks.each do |st|
      stoc = Stock.new(store_id: store_id, item_id: st.item_id, quantity: stock_quantity(st) )

      #unless valid_stock?(stoc)
      #  @inventory.has_error = true
      #  @inventory.error_messages = {item_ids: []} unless @inventory.error_messages
      #  @inventory.error_messages[:quantity] = 'errors.messages.inventory.no_stock'
      #  @inventory.error_messages[:item_ids] << stoc.item_id
      #end

      res = stoc.save && st.update_attribute(:active, false)

      return false unless res
    end

    res
  end

  def stock_quantity(st)
    st.quantity - item_quantity(st.item_id)
  end
end

