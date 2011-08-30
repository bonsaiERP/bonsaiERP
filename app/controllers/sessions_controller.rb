# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  before_filter :check_logged_user, :except => [:destroy]
  def new
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])

    if @user and @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id

      check_logged_user
    else
      user = @user
      @user = User.new(:email => params[:user][:email])
      @user.errors[:email] = "No existe el email que ingreso" unless user
      @user.errors[:password] = "La contraseña que ingreso es incorrecta" if user

      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user] = nil
    session[:organisation] = nil

    redirect_to "/users/sign_in", :notice => "Ha salido correctamente"
  end
end
