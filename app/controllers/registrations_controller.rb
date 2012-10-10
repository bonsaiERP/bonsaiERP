# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  #before_filter :check_logged_user, :except => [:show]
  #before_filter :check_token#, :only => [:new, :create]

  def index
  end

  def show
    @user = User.find_by_id(params[:id])
    if @user and @user.confirm_token(params[:token])
      session[:user_id] = @user.id
      check_logged_user
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
        format.html { redirect_to "/registrations/", :notice => "Se ha registrado exitosamente!. Se le ha enviado un email a <strong>#{@user.email}</strong> con instrucciones para concluir el registro.".html_safe}
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
