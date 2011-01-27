# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlan < ActiveRecord::Base
  acts_as_org

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)
end
