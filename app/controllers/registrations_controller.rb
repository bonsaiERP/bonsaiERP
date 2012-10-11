# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  #before_filter :check_logged_user, :except => [:show]
  #before_filter :check_token#, :only => [:new, :create]

  def index
  end

  def show
    @organisation = Organisation.find_by_tenant(params[:tenant])

    unless @organisation
      redirect_to new_registration_path, alert: 'La empresa no existe.'
      return
    end

    @user = @organisation.users.find_by_confirmation_token(params[:id])
    if @user && @user.confirm_registration
      #QC.enqueue "Organisation.test_job", "La fecha hora es: #{Time.now}"
      session[:user_id] = @user.id
      render text: 'Registrado'
    else
      if @user
        redirect_to new_session_path, alert: "Ya esta registrado."
      else
        redirect_to new_registration_path, alert: "Por favor registrese."
      end
    end
  end

  def new
    @organisation = Organisation.new

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
    def slice_params(data)
      data.slice(:name, :tenant, :email, :password)
    end

    def check_token
      unless params[:registration_token] == "HBJasduf8736454yfsuhdf"
        redirect_to root_path && return
      end
    end
end
