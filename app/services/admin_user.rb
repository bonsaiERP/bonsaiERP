# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to add or update users by the admin
class AdminUser
  attr_reader :email, :attributes

  def initialize(attrs = {})
    @email = attrs[:email]
    @attributes = attrs
  end

  def add_user
    return false unless valid_user?

    user.active_links.build(organisation_id: OrganisationSession.id, rol: get_user_rol, tenant: OrganisationSession.tenant)

    set_user if user.new_record?

    if user.save
      RegistrationMailer.user_registration(self).deliver
    else
      false
    end
  end

  def user
    @user ||= begin
      u = User.active.find_by_email(email)
      u = User.new(attributes) unless u

      u
    end
  end

private
  def set_user
    user.password = random_password
    user.password_confirmation = user.password
    user.set_confirmation_token
    user.change_default_password = true
  end

  # Generates a random password and sets it to the password field
  def random_password(size = 8)
    SecureRandom.urlsafe_base64(size)
  end

  def get_user_rol
    rol = attributes[:rol]
    allowed_roles.include?(rol) ? rol : allowed_roles.last
  end

  def allowed_roles
    @allowed_roles ||= User::ROLES.select {|r| r != 'admin'}
  end

  def valid_user?
    unless user.new_record?

      if Link.where(organisation_id: OrganisationSession.id, user_id: user.id).any?
        user.errors[:email] << I18n.t('errors.messages.user.link_found')

        false
      else
        true
      end
    else
      true
    end
  end
end
