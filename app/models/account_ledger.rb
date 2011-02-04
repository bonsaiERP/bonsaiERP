# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base
  acts_as_org
  # callbacks
  before_save :set_income

  # relationships
  belongs_to :account
  belongs_to :payment

  # validations
  validates_presence_of :account_id, :currency_id
  validates_numericality_of :amount

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

private
  def set_income
    if amount < 0
      self.income = false
    else
      self.income = true
    end
  end
end
