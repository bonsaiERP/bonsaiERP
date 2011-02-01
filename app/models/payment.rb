# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Payment < ActiveRecord::Base
  acts_as_org

  # callbacks
  after_initialize :set_defaults

  # relationships
  belongs_to :transaction

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

private
  def set_defaults

  end
end
