# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  before_filter :check_tenant

  def show
    @organisation = current_organisation

    unless @organisation
      redirect_to new_registration_path, alert: 'La empresa no existe, registrese por favor.'
      return
    end

    @user = @organisation.users.find_by_confirmation_token(params[:id])
    if @user && @user.confirm_registration
      reset_session
      session[:user_id], session[:tenant_creation] = @user.id, true
      redirect_to new_organisation_path, notice: 'Ya esta registrado, ahora ingrese los datos de su empresa.'
    end
  end

  def edit
    @organisation = Organisation.find_by_tenant(session[:tenant])

    respond_to do |format|
      format.html
    end
  end

  def create
    @organisation = Organisation.new(slice_params(params[:organisation]) )

    if @organisation.create_organisation
      @user = @organisation.master_account
      RegistrationMailer.send_registration(@user, @organisation.tenant).deliver
      redirect_to registrations_path, notice: "Se ha registrado exitosamente!."
    else
      render 'new'
    end
  end

  private
    def check_tenant
      if PgTools.schema_exists?(request.subdomain)
        redirect_to new_session_url(host: UrlTools.domain), alert: "Por favor ingrese."
        return
      end
    end
end
