# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionDetail < ActiveRecord::Base

  ########################################
  # Relationships
  belongs_to :item, inverse_of: :transaction_details

  # Validations
  validates_presence_of :item_id, :item
  validates_numericality_of :quantity, greater_than: 0

  # Delegations
  delegate :created_at, to: :transaction, prefix: true

  def total
    price * quantity
  end

  def valued_balance
    price * balance
  end

  def changed_price?
    if transaction.class.to_s == "Income"
      not(price == original_price_currency)
    else
      false
    end
  end

  def original_price_currency
    ( original_price.to_f/transaction.exchange_rate ).round(2)
  end

  def subtotal
    price * quantity
  end

  def data_hash
    {
      original_price: original_price, 
      price: price, 
      quantity: quantity, 
      subtotal: subtotal
    }
  end

private
  def set_defaults
    self.price ||= 0
    self.quantity ||= 0
  end

  # sets the original price of the item
  def set_original_price
    self.original_price = item.price
  end

  # Sets the quantity left to deliver or recive for a transaction
  def set_balance
    self.balance = self.quantity
  end
end
