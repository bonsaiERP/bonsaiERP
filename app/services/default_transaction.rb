# encoding: utf-8
class DefaultTransaction < BaseService

private
  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end
end
