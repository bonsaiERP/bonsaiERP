module Models::User::Authentication
  extend ActiveSupport::Concern

  included do 
    after_create :set_token_and_send_email
  end

  module InstanceMethods
    def confirmated?
      confirmed_at.present?
    end

    def confirm_token(token)
      return false if confirmated?

      if confirmation_token === token
        self.confirmed_at = Time.zone.now
        self.save(:validate => false)
      else
        false
      end
    end

    # Returns self if the password is correct, otherwise false.
    def authenticate(unencrypted_password)
      if confirmed_at.blank?
        self.errors[:base] << I18n.t("errors.messages.user.confirm")
        return false
      end

      if BCrypt::Password.new(password_digest) == (salt + unencrypted_password)
        self
      else
        false
      end
    end

    # Encrypts the password into the password_digest attribute.
    def password=(unencrypted_password, size = 16)
      @password = unencrypted_password
      unless unencrypted_password.blank?
        self.salt = SecureRandom.urlsafe_base64(16)
        self.password_digest = BCrypt::Password.create(salt + unencrypted_password)
      end
    end

    # Resets the password to allow edit the password
    def reset_password
      self.reset_password_token = SecureRandom.urlsafe_base64(16)
      self.reset_password_sent_at = Time.zone.now
      self.save
    end

    def verify_reset_password()

    end

    private
    def set_token_and_send_email
      self.confirmation_token = SecureRandom.base64(12)
      RegistrationMailer.send_registration(self).deliver
      self.save
    end
  end
end
