# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Contact < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_save :change_nl2br, :unless => lambda { |c| c.address.blank? }

  # TYPES = [ 'Cliente', 'Proveedor', 'Cliente/Proveedor' ]

  validates_presence_of :name, :organisation_name
  #, :ctype
  #  validates_inclusion_of :ctype, :in => TYPES

  attr_accessible :name, :organisation_name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info
  
  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

private

  # Format addres to present on the
  def change_nl2br
    self.address.gsub!("\n", "<br/>")
  end

end
