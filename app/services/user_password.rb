# encoding: utf-8
class UserPassword < BaseService
  attribute :password, String
  attribute :password_confirmation, String
  attribute :old_password, String

  attr_reader :user

  delegate :change_default_password?, to: :user

  # Method to update password even with change_default_password = true
  def update_password
    user.attributes = password_attributes

    return false unless valid_old_password?
    user.save
  end

  def update_default_password
    user.attributes = password_attributes
    user.change_default_password = false

    user.save
  end

  def update_reset_password
    user.attributes = password_attributes
    user.change_default_password = false

    user.save
  end

  # Setter
  def user=(usr)
    raise 'You must assign a user=' unless usr.is_a?(User)
    @user = usr
  end

private
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
