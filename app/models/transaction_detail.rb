# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionDetail < ActiveRecord::Base

  before_create :set_balance

  # Validations
  validates_presence_of :item_id
  validates_numericality_of :quantity, greater_than: 0

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

private
  def set_balance
    self.balance = quantity
  end
end
