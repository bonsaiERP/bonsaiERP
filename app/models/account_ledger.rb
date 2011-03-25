# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org

  # callbacks
  after_initialize :set_defaults
  before_save      :set_income
  after_save       :update_payment,         :if => :payment?
  after_save       :update_account_balance, :if => :conciliation?
  after_destroy    :destroy_payment,        :if => :payment?

  # relationships
  belongs_to :account
  belongs_to :payment
  belongs_to :contact
  belongs_to :currency
  belongs_to :transaction

  attr_accessor  :payment_destroy
  attr_protected :conciliation

  # validations
  validates_presence_of :account_id, :currency_id, :reference
  validates_numericality_of :amount

  # delegates
  delegate :name, :number, :type, :to => :account, :prefix => true
  delegate :amount, :interests_penalties, :date, :state, :to => :payment, :prefix => true
  delegate :name, :symbol, :to => :currency, :prefix => true

  # scopes
  scope :pendent,     where(:conciliation => false)
  scope :conciliated, where(:conciliation => true)

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

  # Updates the payment state, without triggering any callbacks
  def update_payment
    if conciliation == true and payment.present? and not(payment_state == 'paid')
      payment.state = 'paid'
      payment.set_updated_account_ledger(true)
      payment.save(:validate => false)
    end
  end

  # Updates the total amount for the account
  def update_account_balance
    self.account.total_amount = (self.account.total_amount + amount)
    self.account.save
  end

  def payment?
    payment_id.present?
  end

  # destroys a payment, in case the payment calls for destroying the account_ledger
  # the if payment.present? will control if the payment was not already destroyed
  def destroy_payment
    payment.destroy if payment.present?
  end
end
