# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base

  has_secure_password
  include Models::User::Authentication

  # callbacks
  before_validation :set_rolname, :if => :new_record?
  before_create     :create_user_link, :if => :change_default_password?
  before_destroy    :destroy_links
  
  ROLES = ['admin', 'gerency', 'inventory', 'sales']

  attr_accessor :temp_password, :rolname, :active_link, :abbreviation

  # Relationships
  has_many :links, :autosave => true, :dependent => :destroy
  has_many :organisations, :through => :links

  # Validations
  validates_presence_of :email, :password
  validates :email, :format => {
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
    :message => I18n.t("errors.user.email")
  }
  validates :password, :length => {:minimum => 6}

  with_options :if => :new_record? do |u|
    validates_presence_of  :rolname
    validates_inclusion_of :rolname, :in => ROLES
  end

  with_options :if => :change_default_password? do |u|
    u.validates_length_of :abbreviation, :minimum => 2
    u.validates_inclusion_of :rolname, :in => ROLES.slice(1,3)
  end

  #attr_protected :account_type
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :website, :description, :rolname, :address, :rolname, :abbreviation

  def to_s
    unless first_name.blank? and last_name.blank?
      %Q(#{first_name} #{last_name})
    else
      %Q(#{email})
    end
  end

  # Returns the link with te organissation one is logged in
  def link
    @link ||= links.find_by_organisation_id(OrganisationSession.organisation_id)
  end

  # returns the organisation which one is logged in
  def organisation
    Organisation.find(OrganisationSession.organisation_id)
  end

  def rol
    link.rol
  end

  def self.admin_gerency?(val)
    ROLES.slice(0, 2).include? val
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

  # Adds a new user for the company
  def add_company_user(params)
    self.attributes = params
    self.email = params[:email]

    set_random_password
    self.change_default_password = true

    self.save
  end

  # Updates the priviledges of a user
  def update_user_role(params)
    self.link.update_attributes(:rol => params[:rolname], :active => params[:active_link])
  end

  # returns translated roles
  def self.get_roles
    ["Genrencia", "Administración", "Inventario", "Ventas"].zip(ROLES)
  end

  def self.new_user(email, password)
    User.new(:password => password) {|u| u.email = email }
  end

  protected
  # Generates a random password and sets it to the password field
  def set_random_password(size = 8)
    self.password = self.temp_password = SecureRandom.urlsafe_base64(size)
  end


  private
  def create_user_link
    links.build(:organisation_id => OrganisationSession.organisation_id, 
                    :rol => rolname, :creator => false) {|link| 
      link.abbreviation = abbreviation 
    }
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
