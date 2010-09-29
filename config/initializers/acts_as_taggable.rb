# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Changes to the original class in acts_as_taggable_on
ActsAsTaggableOn::Tag.instance_eval do
  acts_as_org
  
  # scopes
  # default_scope where( :organisation_id => OrganisationSession.organisation_id )
  scope :organisation , lambda{ |org| where( :organisation_id => org ) }
end
