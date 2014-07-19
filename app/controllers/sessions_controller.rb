# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  before_action :redirect_www
  skip_before_filter :set_tenant, :check_authorization!
  before_action :check_logged_in, only: %w(new create)
  layout 'sessions'

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)

    case
    when @session.authenticate?
      session[:user_id] = @session.user_id
      flash[:notice] = "Ha ingresado correctamente."
      redirect_to home_url(host: DOMAIN, subdomain: @session.tenant) and return
    else
      flash.now[:error] = 'El email o la contraseña que ingreso son incorrectos.'

      render :new
    end
  end

  def destroy
    reset_session

    redirect_to login_url(host: DOMAIN, subdomain: 'app'), notice: "Ha salido correctamente."
  end


  private

    def check_logged_in
      if session[:user_id] && u = User.active.find(session[:user_id])
        if org = u.organisations.first
          redirect_to home_url(host: DOMAIN, subdomain: org.tenant), notice: 'Ha ingresado correctamente.' and return
        else
          reset_session
        end
      end
    rescue
      reset_session
      redirect_to login_path, error: 'El usuario que ingreso no existe' and return
    end

    def session_params
      params.require(:session).permit(:email, :password)
    end

    def redirect_www
      if request.subdomain == 'www'
        redirect_to "http://bonsaierp.com" and return
      end
    end
end
