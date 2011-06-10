# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerDetail < ActiveRecord::Base
  acts_as_org

  STATES = ["uncon", "con"]
  
  # callbacks
  before_validation :set_state, :if => :new_record?
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
  
  private

  def set_state
    self.state ||= "con"
  end

  # updates it's account
  def update_account_amount
    account.update_attribute(:amount, account.amount + amount)
  end
end
