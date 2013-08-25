# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!
  before_filter :check_logged_in, only: %w(new create)
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

      redirect_to dashboard_url(host: UrlTools.domain, subdomain: @session.tenant) and return

    when(!@session.authenticate? && 'resend_registration' == @session.status)
      RegistrationMailer.send_registration(@session).deliver
      flash[:notice] = "Le hemos reenviado el email de confirmación a #{@session.email}"

      redirect_to registrations_url(subdomain: false) and return

    else
      flash.now[:error] = 'El email o la contraseña que ingreso son incorrectos.'

      render :new
    end
  end

  def destroy
    reset_session

    redirect_to login_url(host: UrlTools.domain, subdomain: false), notice: "Ha salido correctamente."
  end


private
  def check_logged_in
    if session[:user_id] && u = User.active.find(session[:user_id])
      if org = u.organisations.first
        redirect_to dashboard_url(host: UrlTools.domain, subdomain: org.tenant), notice: 'Ha ingresado correctamente.' and return
      else
        binding.pry
        reset_session
      end
    end
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
