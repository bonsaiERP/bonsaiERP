# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # relationships
  belongs_to :currency
  has_many :account_ledgers, :order => "date DESC"
  has_many :payments


  delegate :name, :symbol, :to => :currency, :prefix => true

  #validations
  validates_numericality_of :total_amount, :greater_than_or_equal_to => 0
  validates_presence_of :currency_id
  validate :valid_amount_and_currency, :unless => :new_record?

  # scopes
  #default_scope where(:organisation_id => OrganisationSession.organisation_id)

  def to_s
    "#{name} #{number}"
  end

end
