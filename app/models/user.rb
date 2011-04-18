# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base
  # callbacks
  ROLES = ['admin', 'gerency', 'inventory', 'sales']

  # devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable


  attr_accessor :rolname

  # Relationships
  has_many :links
  has_many :organisations, :through => :links

  #attr_protected :account_type
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :website, :description, :rolname


  def to_s
    unless first_name.blank? and last_name.blank?
      %Q(#{first_name} #{last_name})
    else
      %Q(#{email})
    end
  end

  def link
    @link ||= links.find_by_organisation_id(OrganisationSession.organisation_id)
  end

  def rol
    link.rol
  end

  # Checks the user and the priviledges
  def check_organisation?(organisation_id)
    organisations.map(&:id).include?(organisation_id.to_i)
  end

  # returns translated roles
  def self.get_roles
    ["Administración", "Gerencia", "Inventario", "Ventas"].zip(ROLES)
  end

end
