# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base
  self.table_name = 'common.users'

  # Includes
  include Models::User::Authentication

  ROLES = %w(admin group other).freeze

  ########################################
  # Relationships
  has_many :active_links, inverse_of: :user, autosave: true, dependent: :destroy,
           class_name: 'Link', conditions: {active: true}
  has_many :organisations, through: :active_links

  ########################################
  # Validations
  validates_email_format_of :email, message: I18n.t("errors.messages.user.email")
  validates :email, presence: true, uniqueness: {if: :email_changed?, message: I18n.t('errors.messages.email_taken')}

  with_options if: :change_password? do |u|
    u.validates :password, length: {within: PASSWORD_LENGTH..100 }
  end

  # Scopes
  scope :active, where(active: true)

  # Delegations
  ########################################
  delegate :name, :currency, :address, :tenant, to: :organisation, prefix: true, allow_nil: true
  delegate :active, :rol, :rol=, to: :link, prefix: true, allow_nil: true
  delegate :master_account?, to: :link

  ########################################
  # Methods
  ROLES.each do |_rol|
    define_method :"is_#{_rol}?" do
      link_rol == _rol
    end
  end

  def to_s
    if first_name.present? || last_name.present?
      %Q(#{first_name} #{last_name}).strip
    else
      %Q(#{email})
    end
  end

  # Returns the link with the organissation one is logged in
  def link
    @link ||= active_links.find_by_organisation_id(OrganisationSession.id)
  end

  def tenant_link(tenant)
    active_links.where(tenant: tenant).first
  end

  def active_links?
    active_links.any?
  end

  # Updates the priviledges of a user
  def update_user_role(params)
    self.link.update_attributes(rol: params[:rolname], active: params[:active_link])
  end

  def set_auth_token
    self.update_attribute(:auth_token, SecureRandom.urlsafe_base64(32))
  end

  def reset_auth_token
    self.update_attribute(:auth_token, '')
  end

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
  end

  # returns translated roles
  def self.get_roles
    ["Admin", "Privilegiado", "Operaciones"].zip(ROLES)
  end

  def self.roles_hash
    Hash[ROLES.zip(["Gerencia", "Administración", "Operaciones"])]
  end

private
  def change_password?
    new_record? || !password.nil?
  end

  def valid_password_confirmation
    self.errors.add(:password, I18n.t('errors.messages.confirmation')) unless password === password_confirmation
  end
end
