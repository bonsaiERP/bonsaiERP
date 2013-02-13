# encoding: utf-8
class UserPassword < BaseService
  attribute :password, String
  attribute :password_confirmation, String
  attribute :old_password, String

  delegate :change_default_password?, to: :user

  # Method to update password even with change_default_password = true
  def update_password
    return false unless valid_old_password?

    save_or_set_errors
  end

  def update_default_password
    user.change_default_password = false

    save_or_set_errors
  end

  def update_reset_password(usr)
    raise 'You must assign a user=' unless usr.is_a?(User)
    @user = usr
    user.change_default_password = false
    user.confirmed_at = Time.zone.now

    save_or_set_errors
  end

  # Setter
  def user=(usr = UserSession.user)
    raise 'You must assign a user=' unless usr.is_a?(User)
    @user = usr
  end

  def user
    @user ||= UserSession.user
  end

private
  def save_or_set_errors
    user.attributes = password_attributes

    unless user.save
      set_errors(user)

      false
    else
      true
    end
  end

  def password_attributes
    {password: password, password_confirmation: password_confirmation}
  end

  def valid_old_password?
    res = user.valid_password? old_password

    if res
      true
    else
      user.valid?
      self.errors[:old_password] = I18n.t('errors.messages.invalid')

      false
    end
  end
end
