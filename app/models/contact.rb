class Contact < ActiveRecord::Base
  acts_as_org

  # callbacks

  TYPES = [ 'Cliente', 'Proveedor', 'Cliente/Proveedor' ]

  validates_presence_of :name, :ctype
  validates_inclusion_of :ctype, :in => TYPES

  attr_accessible :name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info, :ctype
  
  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)
  

private


end
