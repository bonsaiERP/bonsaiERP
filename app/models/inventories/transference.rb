# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Transference < Inventories::Form
  attribute :store_to_id, Integer

  validates_presence_of :store_to

  def create
    inventory.store_to_id = store_to_id
    save do
      inventory.save
      update_stocks
      update_stocks_to
    end
  end

  def store_to
    @store_to ||= Store.active.where(id: store_to_id).first
  end

  def stores
    @stores ||= Store.active.where("id != ?", store_id)
  end

  def details_form_name
    'inventories_transference[inventory_details_attributes]'
  end

  private

    def operation
      'trans'
    end

    def update_stocks
      res = true
      stocks.each do |st|
        stoc = Stock.create(store_id: store_id, item_id: st.item_id,
                            quantity: stock_quantity(st), minimum: st.minimum)
        res = stoc.save && st.update_attribute(:active, false)

        return false unless res
      end

      res
    end

    def update_stocks_to
      res = true

      stocks_to.each do |st|
        stoc = Stock.create(store_id: store_to_id, item_id: st.item_id,
                            quantity: stock_to_quantity(st), minimum: st.minimum)
        res = stoc.save && st.update_attribute(:active, false)

        return false unless res
      end

      res
    end

    def stock_quantity(st)
      st.quantity - item_quantity(st.item_id)
    end

    def stock_to_quantity(st)
      st.quantity + item_quantity(st.item_id)
    end
end
