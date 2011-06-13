# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerDetail < ActiveRecord::Base
  acts_as_org

  STATES = ["uncon", "con"]
  
  # callbacks
  before_validation :set_values, :if => :new_record?
  before_create :update_account_amount

  belongs_to :account
  belongs_to :account_ledger
  belongs_to :parent, :class_name => "AccountLedgerDetail", :foreign_key => :account_ledger_detail_id

  validates_presence_of :amount, :reference, :account_id, :operation, :state

  # scopes
  scope :pendent, org.where(:state => "uncon")

  def self.pendent?
    self.pendent.count > 0
  end
  
  def amount_currency
    exchange_rate * amount
  end

  private

  def set_values
    self.exchange_rate ||= 1
    self.state ||= "con"
    self.currency_id ||= account.currency_id
  end

  # updates it's account
  def update_account_amount
    account.amount = account.amount + amount if currency_id == account.currency_id

    tot = account.amount_currency[currency_id].to_f + amount
    account.amount_currency = account.amount_currency.merge(currency_id => tot.round(2) )

    account.save
  end
end
