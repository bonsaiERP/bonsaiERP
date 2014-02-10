# encoding: utf-8
class Session < BaseService
  attr_reader :tenant, :status

  attribute :email, String
  attribute :password, String

  delegate :id, to: :user, prefix: true, allow_nil: true

  validates_presence_of :email, :password

  def authenticate?
    return false unless validated?

    confirmed_registration? && user.valid_password?(password) && user.update_attributes(last_sign_in_at: Time.zone.now)
  end

  def user
    @user ||= User.active.find_by_email(email)
  end

  def tenant
    @tenant ||= user.organisations.order("id").first.tenant
  end

  private

    def confirmed_registration?
      @confirmed_registration ||= begin
        conf = user.confirmed_registration?
        @status = 'resend_registration' unless conf
        conf
      end
    end

    def validated?
      valid? && user.present? && user.active_links?
    end
end
