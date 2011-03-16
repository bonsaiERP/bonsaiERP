# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # relationships
  belongs_to :currency
  has_many :account_ledgers, :order => "created_at DESC", :dependent => :destroy
  has_many :payments

  attr_accessor :amount
  attr_protected :total_amount

  delegate :name, :symbol, :code, :to => :currency, :prefix => true


  #validations
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :if => :new_record?
  validates_presence_of :currency_id
  validate :valid_currency_not_changed, :unless => :new_record?

  # scopes

  def self.json
    h = Hash.new {|h, v| h[v.id] = {:currency_id => v.currency_id , :type => v.type}  }
    Account.org.each {|ac| h[ac] }
    h
  end

  # If update occurs it should not allow
  def valid_currency_not_changed
    self.errors.add(:base, "No puede modificar la moneda") if changes[:currency_id]
  end
end
