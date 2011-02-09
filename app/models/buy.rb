# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Buy < Transaction
  acts_as_org


  STATES = ["draft", "aproved", "paid"]

  belongs_to :supplier, :foreign_key => 'contact_id'

  attr_accessor :store_id
  #scope :pay, :conditions => { :organisation_id => OrganisationSession.id, :state => 'due' }
  #scope :aprove, :conditions => { :organisation_id => OrganisationSession.id, :state => 'draft' }
  #scope :all, :conditions => { :organisation_id => OrganisationSession.id }

end
