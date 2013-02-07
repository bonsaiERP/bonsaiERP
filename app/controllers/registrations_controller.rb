# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  before_filter :check_tenant
  skip_before_filter :set_tenant, :check_authorization!

  def new
    @registration = Registration.new
  end

  def show
    @organisation = current_organisation

    unless @organisation
      redirect_to new_registration_url(host: UrlTools.domain), alert: 'La empresa no existe, registrese por favor.'
      return
    end

    @user = @organisation.users.find_by_confirmation_token(params[:id])
    if @user && @user.confirm_registration
      reset_session
      session[:user_id], session[:tenant_creation] = @user.id, true
      redirect_to new_organisation_path, notice: 'Ya esta registrado, ahora ingrese los datos de su empresa.'
    end
  end

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

  def check_tenant
    if request.subdomain.present? && PgTools.schema_exists?(request.subdomain)
      redirect_to new_session_url(host: UrlTools.domain), alert: "Por favor ingrese."
      return
    elsif request.subdomain.present?
      redirect_to new_registration_url(host: UrlTools.domain) and return
    end
  end
end
