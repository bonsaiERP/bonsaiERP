# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::In < Inventories::Form

  def create
    save { update_stocks && inventory.save }
  end

  def details_form_name
    'inventories_in[inventory_details_attributes]'
  end

  private

    def operation
      'in'
    end

    def update_stocks
      stocks.all? do |st|
        stock = Stock.new(store_id: store_id, item_id: st.item_id, quantity: stock_quantity(st), minimum: st.minimum )

        stock.save && st.update_attribute(:active, false)
      end
    end

    def stock_quantity(st)
      st.quantity + item_quantity(st.item_id)
    end
end
