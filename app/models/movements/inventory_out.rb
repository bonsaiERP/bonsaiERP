# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::InventoryOut < Inventories::Form
  attribute :account_id, Integer

  attr_reader :movement

  validate :item_quantities

  def save
    res = valid?

    save_out if res

    set_errors(@inventory) unless res

    res
  end

private
  def save_out
    res = true

    commit_or_rollback do
      res = inventory.save
      res = res && update_stocks
      res && movement.save
    end
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
end
