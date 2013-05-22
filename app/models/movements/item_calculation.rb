# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::ItemCalculation < Struct.new(:movement)
  delegate :items, to: :movement

  def subtotal
    items.inject(0) {|sum, det| sum += det.total }
  end

  def original_total
    items.inject(0) {|sum, det| sum += det.quantity.to_f * det.original_price.to_f }.to_d
  end

  def inventory_balance
    items.inject(0) {|sum, det| sum += det.balance * det.price }
  end

  def items_left
    items.inject(0) {|sum, det| sum += det.balance }
  end
end
