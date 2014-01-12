# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Out < Inventories::Form

  def create
    res = true
    save do
      res = update_stocks
      Inventories::Errors.new(inventory, stocks).set_errors
      res && inventory.save
    end
  end

  def details_form_name
    'inventories_out[inventory_details_attributes]'
  end

  private

    def operation
      'out'
    end

    def update_stocks
      res = true
      new_stocks = []
      stocks.each do |st|
        stoc = Stock.new(store_id: store_id, item_id: st.item_id,
                         quantity: stock_quantity(st), minimum: st.minimum)

        res = stoc.save && st.update_attribute(:active, false)
        new_stocks << stoc

        return false unless res
      end

      klass_details.stocks = new_stocks

      res
    end

    def stock_quantity(st)
      st.quantity - item_quantity(st.item_id)
    end
end

