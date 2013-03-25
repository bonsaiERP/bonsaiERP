class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :price, :buy_price, :label

  def label
    object.to_s
  end

  def value
    id
  end
end
