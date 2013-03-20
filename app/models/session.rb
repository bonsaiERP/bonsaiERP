# encoding: utf-8
class Session < BaseService
  attr_reader :tenant

  attribute :email, String
  attribute :password, String

  delegate :id, to: :user, prefix: true, allow_nil: true

  validates_presence_of :email, :password

  def authenticate
    return false unless validated?

    resp = check_active_user
    return resp unless true == resp

    resp = check_or_resend_registration_email
    return resp unless true == resp

    user.valid_password?(password)
  end

  def user
    @user ||= User.active.find_by_email(email)
  end

  def tenant
    user.organisations.first.tenant
  end

private
  # Checks if the user confirmed the registration if not it resends the
  # confirmation email and returns a string 'resend_registration_email'
  def check_or_resend_registration_email
    unless user.confirmed_registration?
      RegistrationMailer.send_registration(self).deliver

      'resend_registration_email'
    else
      true
    end
  end

  # Check in the links if the user is active
  def check_active_user
    unless user.links.first.active?
      'inactive_user'
    else
      true
    end
  end

  def validated?
    valid? && user.present?
  end
end
