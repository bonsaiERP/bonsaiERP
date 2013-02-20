# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)

    case @session.authenticate
    when true
      @session.user.set_auth_token
      redirect_to dashboard_url(host: UrlTools.domain, subdomain: @session.tenant, auth_token: @session.user.auth_token) and return
    when 'resend_registration_email'
      redirect_to registrations_path, notice: "Le hemos reenviado el email de confirmación a #{@session.email}"
    when 'inactive_user'
      render file: 'sessions/inactive_user'
    else
      flash.now[:error] = 'El email o la contraseña que ingreso no existen.'
      render'new'
    end
  end

  def destroy
    reset_session

    redirect_to new_session_url(host: request.host), subdomain: '', :notice => "Ha salido correctamente."
  end


private
  # Checks the current user and redirects to the correct path
  # if the user has created the organisation and tenant logins
  # if the user has created the organisation and not tenant => cretes tenant
  #def check_logged_user(user = nil)
    #user = user || current_user
    #org = user.organisations.first

    #unless org
      #redirect_to new_registration_url(host: UrlTools.domain) , error: 'No esta' # TODO
      #return
    #end

    ## TODO: Try to use this to encrypt data
    ## encryptor = ActiveSupport::MessageEncryptor.new(Bonsaierp::Application.config.secret_token)
    ## encryptor.encrypt value
    ## encryptor.decrypt value
    #if PgTools.schema_exists?(org.tenant)
      #case
      #when user.active?
        #user.set_auth_token
        #redirect_to dashboard_url(host: request.domain, subdomain: org.tenant, auth_token: user.auth_token) and return
      #when !user.active?
        #redirect_to new_session_path, error: 'Su usuario esta desactivado, contactese con su administrador de su empresa.' and return
      #end

    #elsif user.master_account_for?(org.id)
      #session[:user_id] = user.id
      #redirect_to new_organisation_url(host: request.domain, subdomain: org.tenant, alert: 'Por favor complete su registro.' ) and return
    #else
      #redirect_to new_session_path and return
    #end
  #end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
