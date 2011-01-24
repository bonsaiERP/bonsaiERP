# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_save :set_details_type

  # relationships
  belongs_to :contact
  belongs_to :currency
  belongs_to :project

  has_many :transaction_details
  has_and_belongs_to_many :taxes, :class_name => 'Tax'

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id )

private
  # Sets the type of the class making the transaction
  def set_details_type
    self.transaction_details.each{ |v| v.type = self.class.to_s }
  end
end
