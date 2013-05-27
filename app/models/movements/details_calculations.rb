# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::DetailsCalculations < Struct.new(:movement)
  delegate :details, to: :movement

  def subtotal
    details.inject(0) {|sum, det| sum += det.total }
  end

  def original_total
    details.inject(0) {|sum, det| sum += det.quantity.to_f * det.original_price.to_f }.to_d
  end

  def balance_inventory
    details.inject(0) {|sum, det| sum += det.balance * det.price }
  end

  def inventory_left
    details.inject(0) {|sum, det| sum += det.balance }
  end
end
