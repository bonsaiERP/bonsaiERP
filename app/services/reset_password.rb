# encoding: utf-8
class ResetPassword < BaseService
  attribute :email, String

  validate :valid_email_present?

  def reset_password
    return false unless valid?

    user.reset_password_token = SecureRandom.urlsafe_base64(32)
    user.reset_password_sent_at = Time.zone.now

    if user.save
      ResetPasswordMailer.send_reset_password(user).deliver
    else
      false
    end
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
