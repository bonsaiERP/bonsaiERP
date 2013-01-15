# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper

  ########################################
  # Relationships
  has_many :account_ledgers

  ########################################
  # Validations
  validates_presence_of :currency, :name
  validates_numericality_of :amount
  validates_inclusion_of :currency, in: CURRENCIES.keys

  ########################################
  # Scopes
  #scope :contact_money, lambda {|*account_ids|
  #  s = self.scoped
  #  s.where( s.table[:accountable_type].eq('Contact')
  #    .and(s.table[:accountable_id].in(account_ids))
  #    .and(s.table[:amount].lt(0))
  #    .or(s.table[:accountable_type].eq('MoneyStore'))
  #  ).order("accountable_type")
  #}
  #scope :contact_money_buy, lambda{|account_ids|
  #  s = self.scoped
  #  s.where( 
  #    s.table[:accountable_type].eq('Contact')
  #    .and(s.table[:accountable_id].in(account_ids))
  #    .and(s.table[:amount].gt(0) )
  #    .or(s.table[:original_type].eq('Staff').and(s.table[:amount].gt(0)) )
  #    .or(s.table[:accountable_type].eq('MoneyStore'))
  #  ).order("accountable_type")
  #}
  scope :to_pay, where("amount < 0")
  scope :to_recieve, where("amount > 0")

  ########################################
  # Methods
  def to_s
    name
  end

  def select_cur(cur_id)
    account_currencies.select {|ac| ac.currency_id == cur_id }.first
  end

  # TODO move this and other methods to a new class
  # Creates an array with the getters and setters for delegation
  def self.getters_setters_array(*attrs)
    attrs + attrs.map {|k| :"#{k}=" }
  end

end
