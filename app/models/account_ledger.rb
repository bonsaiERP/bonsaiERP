# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org
  # callbacks
  before_save :set_income
  after_initialize :set_defaults
  after_save :update_account_balance, :if => :conciliation?

  # relationships
  belongs_to :account
  belongs_to :payment
  belongs_to :contact
  belongs_to :currency
  belongs_to :transaction

  attr_protected :conciliation

  # validations
  validates_presence_of :account_id, :currency_id
  validates_numericality_of :amount

  delegate :name, :number, :to => :account, :prefix => true
  delegate :amount, :interests_penalties, :date, :to => :payment, :prefix => true
  delegate :name, :symbol, :to => :currency, :prefix => true

  # scopes

private
  def set_defaults
    self.conciliation = self.conciliation.nil? ? false : conciliation
  end

  # Determinas if the amount is income or expense
  def set_income
    if amount < 0
      self.income = false
    else
      self.income = true
    end
    true
  end

  # Updates the total amount for the account
  def update_account_balance
    self.account.total_amount = (self.account.total_amount + amount)
    # pdate_attribute(:total_amount, (self.account.total_amount + amount) )
    self.account.save
  end
end
