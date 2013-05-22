# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that helps manage details for Inventory
class Movements::IventoryDetails < Struct.new(:movement, :inventory)

  delegate :details, to: :inventory

  def update_details(&b)
    details.each do |det|
      det = income_detail(det.item_id)
      det.balance = b.call(det, det)
    end
  end

  def valid_details_quantities?(b)
    valid = true

    details.each do |det|
      if b.call(it, movement_detail(det.item_id))
        valid = false
        it.errors.add(:quantity, I18n.t('errors.messages.inventory.movement_quantity'))
      end
    end

    valid
  end

  def movement_detail(item_id)
    movement_details.find {|det| det.item_id === item_id }
  end
end
