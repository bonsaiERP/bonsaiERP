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
      unless valid_stock?(stoc)
        self.errors.add(:base, I18n.t('errors.messages.inventory.no_stock')) if res
        res = false
        detail(stoc.item_id).errors.add(:quantity, I18n.t('errors.messages.inventory_detail.stock_quantity'))
      end

      res = res && stoc.save && st.update_attribute(:active, false)
    end

    res
  end

  def stock_quantity(st)
    st.quantity - item_quantity(st.item_id)
  end
end

