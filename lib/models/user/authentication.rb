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

    private
    def set_token_and_send_email
      self.confirmation_token = SecureRandom.base64(12)
      RegistrationMailer.send_registration(self).deliver
      self.save
    end
  end
end
