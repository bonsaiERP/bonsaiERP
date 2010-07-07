# encoding: utf-8
class Buy < Transaction
  include UUIDHelper
  acts_as_org

  belongs_to :supplier, :foreign_key => 'contact_id'

  attr_accessor :store_id
  #scope :pay, :conditions => { :organisation_id => OrganisationSession.id, :state => 'due' }
  #scope :aprove, :conditions => { :organisation_id => OrganisationSession.id, :state => 'draft' }
  #scope :all, :conditions => { :organisation_id => OrganisationSession.id }


end
