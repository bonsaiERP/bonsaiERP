# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base
  # callbacks
  before_validation :set_rolname, :if => :new_record?#, :unless => :change_default_password?
  after_create      :create_user_link, :if => :change_default_password?
  before_destroy    :destroy_links
  
  ROLES = ['admin', 'gerency', 'inventory', 'sales']

  # devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :temp_password, :rolname

  # Relationships
  has_many :links
  has_many :organisations, :through => :links

  #attr_protected :account_type
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :website, :description, :rolname, :address, :rolname

  validates_presence_of  :rolname, :if => :new_record?
  validates_inclusion_of :rolname, :in => ROLES, :if => :new_record?

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

  def update_password(params)
    self.password                = params[:password]
    self.password_confirmation   = params[:password_confirmation]
    self.change_default_password = false

    self.save
  end

  # Generates a random password and sets it to the password field
  def generate_random_password(size = 8)
    arr = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
    self.temp_password = (0..size).map{ arr[rand(arr.size)] }.join

    self.password              = temp_password
    self.password_confirmation = temp_password
  end

  # returns translated roles
  def self.get_roles
    ["Administración", "Gerencia", "Inventario", "Ventas"].zip(ROLES)
  end

private
  def create_user_link
    l = links.build(:organisation_id => OrganisationSession.organisation_id, :rol => rolname, :creator => false)
    raise AcitveRecord::Rollback unless l.save(:validate => false)
  end

  def destroy_links
    links.destroy_all
  end

  def set_rolname
    unless change_default_password?
      self.rolname = 'admin'
    end
  end
end
