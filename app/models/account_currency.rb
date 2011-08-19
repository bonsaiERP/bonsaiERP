# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountCurrency < ActiveRecord::Base
  include Models::Organisation::NewOrganisation

  # relationships
  belongs_to :account
  belongs_to :currency

  validates_presence_of :currency_id, :account_id
  #validates_numericality_of :amount
  delegate :name, :symbol, :to => :currency, :prefix => true
end
