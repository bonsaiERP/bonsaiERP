# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!
  before_filter :check_allow_registration
  before_filter :check_registration_tenant, only: ['show']

  layout 'sessions'

  # GET /registrations/new
  def new
    @registration = Registration.new
  end

  # GET /registrations/:id
  def show
    reset_session
    @user = current_organisation.users.find_by_confirmation_token(params[:id])

    if @user && @user.confirm_registration
      session[:user_id] = @user.id
      redirect_to new_organisation_path, notice: 'Ya esta registrado, ahora ingrese los datos de su empresa.'
    elsif @user
      # TODO: Create a view
      render text: 'Error'
    else
      redirect_to "http://#{DOMAIN}?error_conf_token"
    end
  end

  # Checks the confirmation_token of users added by admin
  # GET /registrations/new_user
  def new_user
    check_new_user
    reset_session
    @user = current_organisation.users.find_by_confirmation_token(params[:id])

    if @user && @user.confirm_registration
      session[:user_id] = @user.id
      flash[:notice] = 'Ha confirmado su registro correctamente.'
      redirect_to dashboard_path and return
    elsif @user
      # TODO: Create a view
      render text: 'Error' and return
    else
      redirect_to "http://#{DOMAIN}?error_conf_token" and return
    end
  end

  # POST /registrations
  def create
    @registration = Registration.new(registration_params)

    if @registration.register
      RegistrationMailer.send_registration(@registration).deliver
      redirect_to registrations_path, notice: "Le hemos enviado un email a #{@registration.email} con instrucciones para completar su registro."
    else
      render 'new'
    end
  end

private
  def registration_params
    params.require(:registration).permit(:name, :tenant, :email, :password, :password_confirmation)
  end

  def check_registration_tenant
    if request.subdomain.present? && PgTools.schema_exists?(request.subdomain)
      redirect_to new_session_url(host: UrlTools.domain), alert: "Por favor ingrese." and return
    elsif request.subdomain.blank?
      redirect_to new_registration_url(host: UrlTools.domain) and return
    end
  end

  def check_new_user
    unless PgTools.schema_exists?(request.subdomain)
      redirect_to new_registration_url(host: UrlTools.domain) and return
    end
  end

  def check_allow_registration
    redirect_to root_path, alert: 'Llegamos a un limite de registros muy pronto ampliaremos nuestra capacidad' and return unless ALLOW_REGISTRATIONS
  end
end
