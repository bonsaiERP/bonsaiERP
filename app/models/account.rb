# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_create :set_amount
  before_create :create_account_currency

  serialize :amount_currency

  attr_readonly  :initial_amount, :original_type
  attr_protected :amount, :amount_currency

  # relationships
  belongs_to :account_type
  belongs_to :currency
  belongs_to :accountable, :polymorphic => true

  has_many :account_ledgers
  has_many :account_ledger_details
  has_many :account_currencies, :autosave => true

  validates_presence_of :currency_id, :name
  #validates_associated  :currency
  validates_numericality_of :amount

  # validations
  validates_presence_of :name, :accountable_type, :accountable_id

  delegate :symbol, :name, :to => :currency, :prefix => true

  # returns the class for a currency
  def cur(cur_id = nil)
    cur_id ||= currency_id
    account_currencies.find_by_currency_id(cur_id)
  end

  # Returns the amount for one currency
  def amount_currency(cur_id = nil)
    cur_id ||= currency_id
    cur(cur_id).amount
  end

  def to_s
    name
  end

private
  def set_amount
    self.amount ||= 0.0
    self.initial_amount ||= self.amount
  end

  def create_account_currency
    account_currencies.build(
      :currency_id => currency_id, :amount => amount
    )
  end
end
