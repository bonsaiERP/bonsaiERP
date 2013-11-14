# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Controllers::Authentication

  def self.included(base)
    base.instance_eval do
      helper_method :current_user, :user_signed_in?
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id])
  rescue
    false
  end

  protected

    def user_signed_in?
      current_user.present?
    end

    # Sets the session for the organisation
    def set_organisation_session(organisation)
      ret = true

      session[:organisation] = Hash[ OrganisationSession::KEYS.map {|k| [k, organisation.send(k)] } ]

      ret
    end
end
