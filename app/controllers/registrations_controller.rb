# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class RegistrationsController < ApplicationController
  before_filter :check_logged_user
  layout "home"

  def index
  end

  def show
    @user = User.find_by_id(params[:id])
    if @user and @user.confirm_token(params[:token])
      session[:user_id] = @user.id
      redirect_to "/organisations/new"
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
    @user = User.new

    respond_to do |format|
      format.html
    end
  end

  def create
    email, password = params[:user][:email], params[:user][:password]
    @user = User.new_user(email, password)

    respond_to do |format|
      if @user.save
        format.html { redirect_to "/registrations/", :notice => "Se ha registrado exitosamente!. Se le ha enviado un email a <strong>#{@user.email}</strong> con instrucciones para concluir el registro."}
      else
        foramt.html { render 'new'}
      end
    end
  end
end
