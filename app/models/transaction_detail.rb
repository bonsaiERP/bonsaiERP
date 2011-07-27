# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionDetail < ActiveRecord::Base
  acts_as_org
  # callbacks
  after_initialize :set_defaults
  before_save      :set_original_price
  before_save      :set_balance, :if => 'transaction.draft?'
  
  attr_protected :original_price

  # relationships
  belongs_to :transaction
  belongs_to :item

  # validations
  validates_presence_of :item_id
  validates_numericality_of :quantity, :greater_than => 0

  def total
    price * quantity
  end

  def valued_balance
    price * balance
  end

  # Indicates if in an Income the item price has changed
  def changed_price?
    if transaction.type == "Income"
      not(price == original_price)
    else
      false
    end
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
