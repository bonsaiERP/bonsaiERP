class Items::Query < SimpleDelegator
  def initialize(rel = Item)
    super(rel)
  end

  def search_items_with_stock(search, store_id)
    items = active.search(search).limit(20)
    items.map do |v|
      ItemStock.new(v , stocks_hash(items.map(&:id), store_id))
    end
  end

end
