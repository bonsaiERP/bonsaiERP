# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  skip_before_filter :check_authorization!
  before_filter :check_auth_token

  # GET /dashboard
  def index
  end

private
  # TODO: Try to use this to encrypt your data
  # encryptor = ActiveSupport::MessageEncryptor.new(Bonsaierp::Application.config.secret_token)
  # encryptor.encrypt value
  # encryptor.decrypt value
  def check_auth_token
    if params[:auth_token].present?
      user = current_organisation.users.find_by_auth_token(params[:auth_token])

      if user
        session[:user_id] =  user.id
        session[:user_rol] = user.links.first.rol # TODO improve session rol
        #user.reset_auth_token # No need if the token is encrypted
      else
        redirect_to new_session_url(host: UrlTools.domain), error: 'Error al ingresar.'
        return
      end
    else
      check_authorization!
    end
  end
end
