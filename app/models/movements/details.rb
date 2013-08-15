# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::Details < Struct.new(:movement)
  delegate :details, to: :movement

  def set_details
    details.each do |det|
      det.price          = det.price || 0
      det.quantity       = det.quantity || 0
      det.original_price = item_prices[det.item_id]
      det.balance        = balance(det)
    end
  end

  def balance(det)
    det.balance - (det.quantity_was - det.quantity)
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).pluck(:id, :buy_price)]
  end

  def set_details_original_prices
    items.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def item_ids
    @item_ids ||= details.map(&:item_id)
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).pluck(:id, :price)]
  end
end
