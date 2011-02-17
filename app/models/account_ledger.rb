# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org
  # callbacks
  before_save :set_income
  after_save :update_account_balance

  # relationships
  belongs_to :account
  belongs_to :payment

  # validations
  validates_presence_of :account_id, :currency_id
  validates_numericality_of :amount

  delegate :amount, :interests_penalties, :date, :to => :payment, :prefix => true

  # scopes
  #default_scope where(:organisation_id => OrganisationSession.organisation_id)

private
  def set_income
    if amount < 0
      self.income = false
    else
      self.income = true
    end
    true
  end

  def update_account_balance
    self.account.update_attribute(:total_amount, (self.account.total_amount + amount) )
  end
end
