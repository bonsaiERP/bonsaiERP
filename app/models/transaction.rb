# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  acts_as_org

  # relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project

  has_many :transaction_details
  has_and_belongs_to_many :taxes, :class_name => 'Tax'

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id )
end
