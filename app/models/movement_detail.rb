# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MovementDetail < ActiveRecord::Base

  # Validations
  validates_presence_of :item_id
  validates_numericality_of :quantity, greater_than: 0
  validate :balance_is_correct
  validate :change_of_item_id, unless: :new_record?
  validate :quantity_eq_balance, if: :marked_for_destruction?

  delegate :unit_name, :unit_symbol, to: :item, allow_nil: true

  def total
    quantity * price
  end
  alias_method :subtotal, :total

  def changed_price?
    !(price === original_price)
  end

  def data_hash
    {
      id: id,
      item_id: item_id,
      original_price: original_price,
      price: price,
      quantity: quantity,
      subtotal: subtotal
    }
  end

  def valid_for_destruction?
    unless(res = quantity === balance)
      errors.add(:item_id, I18n.t('errors.messages.movement_details.not_destroy'))
      self.quantity = quantity_was
      @marked_for_destruction = false
    end
    res
  end

  private

    def balance_is_correct
      self.errors.add(:item_id, balance_error_message)  if self.balance > quantity
    end

    def balance_error_message
      I18n.t('errors.messages.movement_details.balance')
    end

    def quantity_eq_balance
      self.errors.add(:quantity, "No se puede")  unless balance == quantity
    end

    def change_of_item_id
      self.errors.add(:item_id, I18n.t('errors.messages.movement_details.item_changed'))  if item_id_changed?
    end
end
