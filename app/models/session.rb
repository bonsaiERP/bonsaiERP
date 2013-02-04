# encoding: utf-8
class Session < BaseService
  attr_reader :tenant

  attribute :email, String
  attribute :password, String

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
    @user ||= User.find_by_email(email)
  end

  def tenant
    user.organisations.first.tenant
  end

private
  def check_or_resend_registration_email
    unless user.confirmed_registration?
      RegistrationMailer.send_registration(self).deliver
      'resend_registration_email'
    else
      true
    end
  end

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
