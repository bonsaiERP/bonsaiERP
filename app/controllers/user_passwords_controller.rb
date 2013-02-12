# encoding: utf-8
class UserPasswordsController < ApplicationController
  before_filter :check_change_password!, only: [:new, :create]
  before_filter :check_change_default_password!, only: [:new_default, :create_default]

  # GET user_passwords/new
  def new
    @user_password = UserPassword.new
  end

  # POST user_passwords
  def create
    @user_password = UserPassword.new(password_params)

    if @user_password.update_password
      redirect_to current_user, notice: "Su contraseña ha sido actualizada."
    else
      render 'new'
    end
  end

  # GET user_passwords/new_default
  def new_default
    @user_password = UserPassword.new
  end

  # POST user_passwords/create_default
  def create_default
    @user_password = UserPassword.new(password_params)

    if @user_password.update_default_password
      redirect_to current_user, notice: "Su contraseña ha sido actualizada."
    else
      render 'new_default'
    end
  end

private
  def password_params
    params.require(:user_password).permit(:old_password, :password, :password_confirmation)
  end

  def check_change_password!
    redirect_to new_default_user_passwords_path and return if current_user.change_default_password?
  end

  def check_change_default_password!
    redirect_to new_user_password_path and return unless current_user.change_default_password?
  end
end
