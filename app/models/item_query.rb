class ItemQuery
  def initialize
    @relation = Item
  end

  def search(s)
    @relation.where{(name.like "%#{s}%") | (code.like "%#{s}%")}
  end

  def income_search(s)
    search(s).income
  end
end
