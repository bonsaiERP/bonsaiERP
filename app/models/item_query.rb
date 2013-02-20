class ItemQuery
  def initialize
    @rel = Item
  end

  def search(s)
    @rel.where{(name.like "%#{s}%") | (code.like "%#{s}%")}
  end

  def expense_search(s)
    search(s).active
  end

  def income_search(s)
    search(s).income
  end
end
