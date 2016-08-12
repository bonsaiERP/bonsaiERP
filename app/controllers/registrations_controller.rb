# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!
  #before_filter :check_allow_registration
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
      render text: 'Error' and return
    else
      redirect_to "http://#{DOMAIN}?error_conf_token" and return
    end
  end

  # POST /registrations
  def create
    @registration = Registration.new(registration_params)

    if @registration.register
      #RegistrationMailer.send_registration(@registration).deliver
      redirect_to new_organization_path, notice: t("controllers.registrations.create_notice")
    else
      render :new
    end
  end

  private

    def registration_params
      params.require(:registration).permit(:name, :tenant, :email, :password, :password_confirmation)
    end

    def check_registration_tenant
      if request.subdomain.present? && PgTools.schema_exists?(request.subdomain)
        redirect_to new_session_url(host: DOMAIN), alert: "Por favor ingrese." and return
      elsif request.subdomain.blank?
        redirect_to new_registration_url(host: DOMAIN) and return
      end
    end

    def check_allow_registration
      unless ALLOW_REGISTRATIONS
        redirect_to root_path, alert: 'Llegamos a un limite de registros muy pronto ampliaremos nuestra capacidad' and return
      end
    end
end
