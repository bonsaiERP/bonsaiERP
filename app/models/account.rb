# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # relationships
  belongs_to :currency
  has_many :account_ledgers, :order => "created_at DESC"
  has_many :payments

  delegate :name, :symbol, :to => :currency, :prefix => true

  #validations
  validates_numericality_of :total_amount, :greater_than_or_equal_to => 0
  validates_presence_of :currency_id
  validate :valid_amount_and_currency_not_changed, :unless => :new_record?

  # scopes

  def to_s
    "#{name} #{number}"
  end

  # If update occurs it should not allow
  def valid_amount_and_currency_not_changed
    self.errors.add(:base, "No puede modificar total en cuenta o la moneda") if changes[:total_amount] or changes[:currency_id]
  end
end
