# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountType < ActiveRecord::Base

  include Models::Organisation::NewOrganisation
  
  attr_readonly :account_number

  # callbacks
  before_destroy { self.update_attribute(:active, false) ;false }

  # relationships
  has_many :accounts

  #validations
  validates_presence_of :name

  # scopes
  scope :active, where(:active => true)

end
