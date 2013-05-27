class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :price, :buy_price, :unit_symbol, :unit_name, :label

  def label
    object.to_s
  end

  def value
    id
  end
end
