module Models::User::Authentication
  extend ActiveSupport::Concern

  attr_accessor :password, :password_confirmation

  included do
    before_create :set_confirmation_token
  end

  def confirmed_registration?
    confirmed_at.present?
  end

  def confirm_registration
    return true if confirmed_registration?

    self.confirmed_at = Time.zone.now
    self.save(validate: false)
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

  # Resets the password to allow edit the password
  def reset_password
    ret = true

    self.reset_password_token   = SecureRandom.urlsafe_base64(16)
    self.reset_password_sent_at = Time.zone.now
    self.class.transaction do
      ret = self.save
      ret = ret && ResetPasswordMailer.send_reset_password(self).deliver
      raise ActiveRecord::Rollback unless ret
    end

    ret
  end

  def resend_confirmation
    RegistrationMailer.send_registration(self).deliver
  end

  def verify_token_and_update_password(params)
    unless params[:password] === params[:password_confirmation]
      self.errors[:password] = I18n.t("errors.messages.user.password_confirmation")
      return false
    end

    self.password = params[:password]
    self.reset_password_token = nil

    self.save
  end

  def can_reset_password?
    reset_password_token.present? and ( reset_password_sent_at > Time.zone.now - 1.hour )
  end

  private

    def pepper
      'OLIxRc5aGujs5D/9S8LslEM+DMsY0GdgL8Eg9ldTlXY='
    end

    def set_confirmation_token
      self.confirmation_token = SecureRandom.urlsafe_base64(32)
    end

    def stretches; 10; end
end
