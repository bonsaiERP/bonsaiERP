class UserPassword < BaseService
  attribute :password, String
  attribute :password_confirmation, String
  attribute :old_password, String

  attr_reader :user

  delegate :change_default_password?, to: :user

  # Method to update password even with change_default_password = true
  def update_password
    raise 'You must assign a user=' unless user.is_a?(User)

    user.attributes = password_attributes

    if change_default_password?
      update_default_password
    else
      update_normal_password
    end
  end

  def update_reset_password
    raise 'You must assign a user=' unless user.is_a?(User)

    user.attributes = password_attributes
    user.change_default_password = false
    
    user.save
  end

  # Setter
  def user=(usr)
    @user = usr
  end

private
  def update_normal_password
    user.valid?

    unless user.valid_password?(old_password)
      self.errors.add(:old_password, I18n.t('errors.messages.invalid'))
      return false
    end

    user.save
  end

  def update_default_password
    user.change_default_password = false

    user.save
  end

  def password_attributes
    {password: password, password_confirmation: password_confirmation}
  end
end
