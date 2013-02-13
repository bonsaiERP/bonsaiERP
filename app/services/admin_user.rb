# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to add or update users by the admin
class AdminUser
  attr_reader :user

  def initialize(usr)
    @user = usr
  end

  def add_user
    user.links.build(organisation_id: OrganisationSession.id, rol: get_user_rol, tenant: OrganisationSession.tenant)
    set_user

    if user.save
      RegistrationMailer.user_registration(self).deliver
    else
      false
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
    allowed_roles.include?(user.rol) ? user.rol : allowed_roles.last
  end

  def allowed_roles
    @allowed_roles ||= User::ROLES.select {|r| r != 'admin'}
  end
end
