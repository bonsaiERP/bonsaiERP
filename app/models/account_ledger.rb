# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org

  # callbacks
  after_initialize :set_defaults
  before_save :set_income
  after_save :update_account_payment, :if => :payment?
  after_save :update_account_balance, :if => :conciliation?

  # relationships
  belongs_to :account
  belongs_to :payment
  belongs_to :contact
  belongs_to :currency
  belongs_to :transaction

  attr_protected :conciliation

  # validations
  validates_presence_of :account_id, :currency_id, :reference
  validates_numericality_of :amount

  delegate :name, :number, :to => :account, :prefix => true
  delegate :amount, :interests_penalties, :date, :to => :payment, :prefix => true
  delegate :name, :symbol, :to => :currency, :prefix => true

  # scopes

  # Updates the conciliation state
  def conciliate_account
    self.conciliation = true
    self.save
  end

private
  def set_defaults
    self.conciliation = self.conciliation.nil? ? false : conciliation
  end

  def payment?
    payment_id.present? and conciliation?
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

  # Updates the payment state
  def update_account_payment
    payment.state = 'paid'
    payment.save
  end

  # Updates the total amount for the account
  def update_account_balance
    self.account.total_amount = (self.account.total_amount + amount)
    self.account.save
  end
end
