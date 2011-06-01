# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < ActiveRecord::Base

  acts_as_org

  # callbacks
  before_create :create_account

  # delegations
  delegate :name, :symbol, :code, :plural, :to => :currency, :prefix => true

private
  def create_account

  end
end
