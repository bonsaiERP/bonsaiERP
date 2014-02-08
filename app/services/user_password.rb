# encoding: utf-8
class UserPassword < BaseForm
  attribute :password, String
  attribute :password_confirmation, String
  attribute :old_password, String

  attr_reader :tenant

  delegate :change_default_password?, to: :user

  validates_length_of :password, minimum: PASSWORD_LENGTH, maximum: 32
  validate :valid_old_password

  # Method to update password even with change_default_password = true
  def update_password
    return false  unless valid?

    user.password = password
    user.save
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

    def password_attributes
      { password: password, password_confirmation: password_confirmation }
    end

    def valid_old_password
      unless user.valid_password? old_password
        errors.add(:old_password, I18n.t('errors.messages.invalid'))
      end
    end

    def valid_password_confirmation?
      unless password == password_confirmation
        errors.add(:password, I18n.t('errors.messages.confirmation'))
      end
    end
end
