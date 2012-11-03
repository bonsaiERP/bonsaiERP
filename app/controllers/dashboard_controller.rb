# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  skip_before_filter :check_authorization!, only: ['index']
  before_filter :check_auth_token, only: [ 'index' ]

  # GET /dashboard
  def index
  end

  # GET /config
  def configuration
    @users = User.order(:id).all
    @org   = current_organisation
  end

private
  def check_auth_token
    if params[:auth_token].present?
      user = current_organisation.users.find_by_auth_token(params[:auth_token])

      if user
        session[:user_id] =  user.id
        session[:user_rol] = user.links.first.rol # TODO improve session rol
        user.reset_auth_token
      else
        redirect_to new_session_url(host: UrlTools.domain), error: 'Error al ingresar.'
        return
      end
    else
      check_authorization!
    end
  end
end
