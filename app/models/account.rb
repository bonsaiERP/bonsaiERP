# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_create :set_amount

  attr_protected :amount

  # relationships
  belongs_to :account_type
  belongs_to :currency
  belongs_to :accountable, :polymorphic => true

  has_many :account_ledger_details

  validates_presence_of :currency_id, :name
  validates_numericality_of :amount

  # validations
  validates_presence_of :name, :accountable_type, :accountable_id

  delegate :symbol, :name, :to => :currency, :prefix => true

private
  def set_amount
    self.amount ||= 0.0
    self.initial_amount ||= self.amount
  end

end
