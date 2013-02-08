# encoding: utf-8
class ResetPassword < BaseService
  attribute :email, String

  validate :valid_email_present

  def reset_password
    user.reset_password_token = SecureRandom.urlsafe_base64(32)
    user.reset_password_sent_at = Time.zone.now

    if user.save
      ResetPasswordMailer.send_reset_password(user).deliver
    else
      false
    end
  end

private
  def valid_email_present?
    user.present?
  end

  def user
    @user ||= User.active.where(email: email).first
  end
end
