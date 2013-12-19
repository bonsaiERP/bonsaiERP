class Items::Query < Item
  class << self
    def expense_search(s)
      search(s).active
    end

    def income_search(s)
      search(s).income
    end

    def for_sale(val)
      if val == 'true' || val == true
        where(for_sale: true)
      else
        where(for_sale: false)
      end
    end
  end
end
