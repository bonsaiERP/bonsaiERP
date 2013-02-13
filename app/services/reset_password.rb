# encoding: utf-8
class ResetPassword < BaseService
  attribute :email, String

  validate :valid_email_present?

  def update_reset_password(usr)
    raise 'You must pass a User objtec' unless user.is_a?(User)
    @user = usr
    confirm_user_registration
    user.change_default_password = true

    user.save
  end

private
  def confirm_user_registration
    user.confirmed_at = Time.zone.now unless user.confirmed_registration?
  end

  def valid_email_present?
    unless user.present?
      self.errors.add(:email, I18n.t('errors.messages.user.email_not_found'))
    end
  end

  def user
    @user ||= User.active.where(email: email).first
  end
end
