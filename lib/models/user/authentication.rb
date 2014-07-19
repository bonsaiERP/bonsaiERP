module Models::User::Authentication
  attr_accessor :password, :password_confirmation

  def self.included(base)
    base.before_create :set_confirmation_token
  end

  def confirm_registration
    return true  if confirmed_at?

    update_attribute(:confirmed_at, Time.zone.now)
  end

  def valid_password?(unencrypted_password)
    peppered_password = [unencrypted_password, pepper].join
    ::BCrypt::Engine.hash_secret(peppered_password, password_salt, stretches) === self.encrypted_password
  end

  def password=(unencrypted_password)
    instance_variable_set(:@password, unencrypted_password)

    self.password_salt = ::BCrypt::Engine.generate_salt
    peppered_password = [unencrypted_password, pepper].join
    self.encrypted_password = ::BCrypt::Engine.hash_secret(peppered_password, password_salt, stretches)
  end

  private

    def pepper
      Rails.application.secrets.pepper
    end

    def set_confirmation_token
      self.confirmation_token = SecureRandom.urlsafe_base64(32)
    end

    def stretches; 10; end
end
