# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base

  has_secure_password
  
  include Models::User::Authentication

  # callbacks
  #before_validation :set_rolname, :if => :new_record?
  before_create     :create_user_link, :if => :change_default_password?
  before_destroy    :destroy_links
  
  ABBREV = "GEREN"
  ROLES = ['admin', 'gerency', 'operations'].freeze

  ROLES.each do |v|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{v}?
        rol == "#{v}"
      end
    CODE
  end

  attr_accessor :temp_password, :rolname, :active_link, :old_password, :send_email#, :abbreviation
  attr_reader :created_user

  # Relationships
  has_many :links, :autosave => true, :dependent => :destroy
  has_many :organisations, :through => :links

  # Validations
  validates_presence_of :email
  validates :email, :format => {
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
    :message => I18n.t("errors.messages.user.email")
  }, :uniqueness => {:if => :email_changed?}
  validates_inclusion_of :rol, :in => ROLES
  validates_inclusion_of :rolname, :in => ROLES, :if => "rol.blank?"

  with_options :if => :new_record? do |u|
    #u.validates_inclusion_of :rolname, :in => ROLES
    u.validates :password, :length => {:minimum => 6}
  end

  #attr_protected :account_type
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :website, 
    :description, :rolname, :address, :abbreviation, :old_password

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

  def send_email?
    !!send_email
  end

  # returns the organisation which one is logged in
  def organisation
    Organisation.find(OrganisationSession.organisation_id)
  end

  def self.admin_gerency?(val)
    ROLES.slice(0, 2).include? val
  end

  # Checks the user and the priviledges
  def check_organisation?(organisation_id)
    organisations.map(&:id).include?(organisation_id.to_i)
  end

  def update_default_password(params)
    pwd, pwd_conf = params[:password], params[:password_confirmation]

    unless pwd == pwd_conf
      self.errors[:password] << I18n.t("errors.messages.user.password_confirmation")
      return false
    end

    PgTools.reset_search_path
    u = User.find_by_id(UserSession.user_id)
    u.change_default_password = false
    u.password = pwd

    u.save
  end

  def update_password(params)
    return false if change_default_password?

    PgTools.reset_search_path
    unless authenticate(params[:old_password])
      self.errors[:old_password] << I18n.t("errors.messages.user.wrong_password")
      return false
    end

    unless params[:password] === params[:password_confirmation]
      self.errors[:password] << I18n.t("errors.messages.user.password_confirmation")
      return false
    end

    self.password = params[:password]

    self.save
  end

  # Adds a new user for the company
  def add_company_user(params)
    PgTools.set_search_path PgTools.get_schema_name(OrganisationSession.organisation_id)
    total_users = User.count
    PgTools.reset_search_path
    org = Organisation.find(OrganisationSession.organisation_id)
    acc = ClientAccount.find(org.client_account_id)
    
    if total_users >= acc.users
      self.errors[:base] = I18n.t("errors.messages.user.user_limit")
      return false
    end

    self.attributes = params
    self.email = params[:email]

    set_random_password
    self.change_default_password = true
    
    res = true
    
    User.transaction do
      PgTools.set_search_path "public"
      u = User.new_user(params[:email], params[:password])
      u.password = self.temp_password
      u.rol = params[:rolname]
      u.change_default_password = true
      u.send_email = true
      res = u.save
      @created_user = u

      PgTools.reset_search_path
      PgTools.set_search_path PgTools.get_schema_name OrganisationSession.organisation_id
      u2 = User.new(params) {|us| us.id = u.id}
      u2.password = self.temp_password
      u2.rol = params[:rolname]
      u2.send_email = false
      u2.change_default_password = true
      u2.active = true
      res = res && u2.save
      raise ActiveRecord::Rollback unless res
    end

    res
  end

  # Updates the priviledges of a user
  def update_user_role(params)
    self.link.update_attributes(:rol => params[:rolname], :active => params[:active_link])
  end

  # returns translated roles
  def self.get_roles
    ["Gerencia", "Administración", "Operaciones"].zip(ROLES)
  end

  def self.roles_hash
    Hash[ROLES.zip(["Gerencia", "Administración", "Operaciones"])]
  end

  def self.new_user(email, password)
    User.new(:password => password ) {|u| 
      u.email = email 
    }
  end

  def update_user_attributes(params)
    rol = params[:rolname]
    params.delete(:email)
    rol = ROLES[1,2].last unless ROLES[1,2].include?(rol)
    self.attributes = params
    self.rol = rol

    self.save
  end

  # Only used when creating a new user
  def save_user
    self.confirmation_token = SecureRandom.base64(12)
    self.rol = User::ROLES.first
    self.send_email = true
    self.save
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

  #def set_rolname
  #  unless change_default_password?
  #    self.rolname = 'admin'
  #  end
  #end

end
