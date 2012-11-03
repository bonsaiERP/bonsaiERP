# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!

  def new
    @user = User.new
  end

  # Resend confirmation token
  def show
    @user = User.find_by_id(params[:id])

    case
      when( @user && !@user.confirmed_registration? )
        @user.resend_confirmation
      when( @user and @user.confirmed_registration? )
        redirect_to 'new'
      else
        flash[:notice] = "Por favor registrese gratuitamente si desea usar el sistema."
        redirect_to new_registration_path
    end
  end

  def create
    reset_session
    @user = User.find_by_email(params[:user][:email])

    if @user
      case
      when( @user.confirmed_registration? && @user.valid_password?(params[:user][:password]) )
        UserSession.current_user = @user
        check_logged_user(@user)
      when( !@user.confirmed_registration? )
        @user.resend_confirmation
        redirect_to registrations_path, notice: "Le hemos reenviado un email a #{@user.email} con instrucciones para completar su registro."
      end
    else
      err = 'El email que ingreso no existe.'
      @user = User.new(:email => params[:user][:email])
      @user.errors[:email] << err
      render'new', error: err
    end
  end

  def destroy
    reset_session
    redirect_to new_session_url(host: UrlTools.domain), :notice => "Ha salido correctamente."
  end


private
  # Checks the current user and redirects to the correct path
  # if the user has created the organisation and tenant logins
  # if the user has created the organisation and not tenant => cretes tenant
  def check_logged_user(user = nil)
    user = user || current_user
    org = user.organisations.first
    unless org
      redirect_to new_registration_url(host: UrlTools.domain) , error: 'No esta' # TODO
      return
    end

    if PgTools.schema_exists?(org.tenant)
      case
      when user.active?
        user.set_auth_token
        redirect_to dashboard_url(host: UrlTools.domain, subdomain: org.tenant, auth_token: user.auth_token)
        return
      when !user.active?
        redirect_to new_session_path, error: 'Su usuario esta desactivado, contactese con su administrador de su empresa.'
        return
      end

    else
      redirect_to new_organisation_url(host: 'host', subdomain: org.tenant, alert: 'Por favor complete su registro.' )
    end
  end

end

class LoggedUser
  attr_reader :controller

  def initialize(cont)
    @controller = cont
  end

  def check_logged_user

  end
end
