# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  #before_filter :check_logged_user, :except => [:show]
  #before_filter :check_token#, :only => [:new, :create]

  def index
  end

  def show
    @user = User.find_by_confirmation_token(params[:id])
    if @user && @user.confirm_registration
      session[:user_id] = @user.id
      render text: 'Registrado'
    else
      if @user
        flash[:warning] = "Ya esta registrado."
        redirect_to new_session_path
      else
        flash[:warning] = "Por favor registrese."
        redirect_to new_registration_path
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

    respond_to do |format|
      if @organisation.create_organisation
        @user = @organisation.master_account
        RegistrationMailer.send_registration(@user).deliver
        format.html { redirect_to registrations_path, notice: "Se ha registrado exitosamente!." }
      else
        format.html { render 'new'}
      end
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
