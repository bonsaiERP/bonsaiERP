# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ResetPasswordsController < ApplicationController
  #include ActionView::Helpers::UrlHelper
  before_filter :reset_search_path
  before_filter :check_if_can_reset_password, :only => [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:user][:email])

    case
    when( @user and @user.confirmated?)
      @user.reset_password
      render "reset"
    when( @user and not(@user.confirmated?) )
      redirect_to session_path(@user.id)
    else
      @user = User.new
      @user.errors[:email] << "El email que ingreso no existe en nuestro sistema"
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.verify_token_and_update_password(params[:user])
      flash[:notice] = "Se ha actualizado correctamente su contraseña."
      session[:user_id] = @user.id
      check_logged_user
    else
      render "edit"
    end
  end

  private

  def check_if_can_reset_password
    id = params[:id] || params[:user][:id]
    token = params[:reset_password_token] || params[:user][:reset_password_token]
    @user = User.find_by_id_and_reset_password_token(id, token)

    unless @user and @user.can_reset_password?
      flash[:warning] = "No se puede cambiar de contraseña."
      redirect_to new_reset_password_path
    end
  end

  def reset_search_path
    PgTools.reset_search_path
  end
end
