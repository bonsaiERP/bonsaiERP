# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  before_filter :check_tenant
  skip_before_filter :set_tenant, :check_authorization!

  def new
    @organisation = Organisation.new
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
    @organisation = Organisation.new(organisation_params)

    # TODO refactor create_organisation, really nasty
    if @organisation.create_organisation
      @user = @organisation.master_account
      RegistrationMailer.send_registration(@user, @organisation.tenant).deliver
      redirect_to registrations_path, notice: "Le hemos enviado un email a #{@user.email} con instrucciones para completar su registro."
    else
      render 'new'
    end
  end

private
  def organisation_params
    params.require(:organisation).permit(:name, :tenant, :email, :password)
  end

  def check_tenant
    if request.subdomain.present? && PgTools.schema_exists?(request.subdomain)
      redirect_to new_session_url(host: UrlTools.domain), alert: "Por favor ingrese."
      return
    end
  end
end
