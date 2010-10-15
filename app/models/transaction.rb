# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id )
end
