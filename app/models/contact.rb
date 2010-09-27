class Contact < ActiveRecord::Base
  acts_as_org

  # callbacks
  # before_save :create_or_update_item

  # has_one :item, :as => :itemable, :dependent => :destroy

  TYPES = [ 'Cliente', 'Proveedor', 'Cliente/Proveedor' ]

  validates_presence_of :name, :ctype
  validates_inclusion_of :ctype, :in => TYPES

  attr_accessible :name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info, :ctype
  
  default_scope where(:organisation_id => OrganisationSession.id)
  
  # scopes
  #scope :all, where(:organisation_id => OrganisationSession.id)

private

  #def self.all
  #  Contact.where( :organisation_id => OrganisationSession.id )
  #end

end
