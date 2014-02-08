# encoding: utf-8
class ResetPasswordEmail < BaseForm
  attribute :email, String

  validate :valid_email_present?

  attr_reader :tenant

  def reset_password
    return false  unless valid?

    user.reset_password_token = SecureRandom.urlsafe_base64(32)
    user.reset_password_sent_at = Time.zone.now

    save_and_send_email
  end

  def user
    @user ||= User.active.where(email: email).first
  end

  private

    def save_and_send_email
      if tenant_exists?
        user.save
        ResetPasswordMailer.send_reset_password(user).deliver
      elsif @link.master_account?
        user.save
        RegistrationMailer.send_registration(self).deliver
      else
        false
      end
    end

    def tenant_exists?
      if user.active_links.find {|l| PgTools.schema_exists?(l.tenant) }
        true
      else
        @link = user.active_links.first
        @tenant = @link.tenant
        false
      end
    end

    def sends_email_depending
      if PgTools.schema_exists?(user.organisations.first)
        ResetPasswordMailer.send_reset_password(user).deliver
      end
    end

    def confirm_user_registration
      user.confirmed_at = Time.zone.now unless user.confirmed_registration?
    end

    def valid_email_present?
      unless user.present?
        self.errors.add(:email, I18n.t('errors.messages.user.email_not_found'))
      end
    end
end
