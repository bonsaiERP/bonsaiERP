# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Transference < Inventories::Form
  attribute :store_to_id, Integer

  validates_presence_of :store_to

  def create
    save do
      @inventory.save
    end
  end

  def store_to
    Store.active.where(id: store_to_id).first
  end

  def inventory
    super
    @inventory.store_to_id = store_to_id
    @inventory
  end

private
  def operation
    'trans'
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
