# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # relationships
  belongs_to :currency
  has_many :account_ledgers

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)
end
