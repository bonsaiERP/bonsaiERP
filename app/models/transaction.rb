# encoding: utf-8
class Transaction < ActiveRecord::Base
  acts_as_org

  scope :pay, :conditions => { :organisation_id => OrganisationSession.id, :state => 'due' }
  scope :aprove, :conditions => { :organisation_id => OrganisationSession.id, :state => 'draft' }
  scope :all, :conditions => { :organisation_id => OrganisationSession.id }

end
