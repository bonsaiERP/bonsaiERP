# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Controllers::Authentication

  def current_user
    return false unless session[:user_id].present?
    begin
      @current_user ||= User.find(session[:user_id])
    rescue
      false
    end
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

  def self.helpers
    [:current_user, :user_signed_in?]
  end

end
