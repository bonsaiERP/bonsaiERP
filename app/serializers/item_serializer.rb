#class ItemSerializer < ActiveModel::Serializer
#  attributes :id, :name, :code, :price, :buy_price, :unit_symbol, :unit_name, :label
#
#  def label
#    object.to_s
#  end
#
#  def value
#    id
#  end
#end

class ItemSerializer
  def income(items)
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s
      }
    end
  end

  def expense(items)
    items.map do |item|
      {
        id: item.id, name: item.name,
        code: item.code, price: item.buy_price,
        unit_symbol: item.unit_symbol, unit_name: item.unit_name, label: item.to_s
      }
    end
  end
end
