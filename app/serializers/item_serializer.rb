class ItemSerializer
  attr_reader :items, :store_id

  def income(items)
    @items = items
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s
      }
    end
  end

  def expense(items)
    @items = items
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.buy_price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s
      }
    end
  end

  def inventory(items, store_id)
    @items, @store_id = items, store_id
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.buy_price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s,
        stock: get_stock(item.id)
      }
    end
  end

  private

    def get_stock(item_id)
      stocks_hash.fetch(item_id) { 0 }
    end

    def stocks_hash
      Hash[stocks(items.map(&:id)).map { |v| [v.item_id, v.quantity] }]
    end

    def stocks(item_ids)
      @stocks ||= Stock.active.select('item_id, quantity').where(store_id: store_id, item_id: item_ids)
    end
end
