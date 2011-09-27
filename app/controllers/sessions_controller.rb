# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  before_filter :check_logged_user, :except => [:destroy]

  def new
    @user = User.new
  end

  # Resend confirmation token
  def show
    begin
      @user = User.find_by_id(params[:id])
      @user.resend_confirmation
    rescue
      redirect_to "/"
    end
  end

  def create
    @user = User.find_by_email(params[:user][:email])

    case
      when(@user and @user.confirmated? and @user.authenticate(params[:user][:password]) )
        session[:user_id] = @user.id
        check_logged_user
      when(@user and @user.confirmated?)
        @user.errors[:password] = "La contraseña que ingreso es incorrecta"
        render "new"
      when(@user and not(@user.confirmated?))
        redirect_to session_path(:id => @user.id)
      else
        @user = User.new(:email => params[:user][:email])
        @user.errors[:email] = "El email que ingreso no existe"
        render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user] = nil
    session[:organisation] = nil
    session[:current_user] = nil

    redirect_to "/users/sign_in", :notice => "Ha salido correctamente"
  end
end
