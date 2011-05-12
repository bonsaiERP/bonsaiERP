# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BaseApp < ActionController::Metal

  protected

  def set_organisation_session
    OrganisationSession.set session[:organisation]
  end
end
