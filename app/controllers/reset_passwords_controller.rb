# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ResetPasswordsController < ApplicationController
  #include ActionView::Helpers::UrlHelper
  layout 'sessions'
  skip_before_filter :set_tenant, :check_authorization!
  before_filter :reset_search_path
  before_filter :find_user_or_redirect!, only: [:edit, :update]

  def index
  end

  # GET /reset_passwords/new
  def new
    @reset_password = ResetPassword.new
  end

  # POST /reset_passwords
  def create
    @reset_password = ResetPassword.new(reset_params)

    if @reset_password.reset_password
      redirect_to reset_passwords_path
    else
      flash.now[:error] = 'El email que ingreso no existe.'
      render 'new'
    end
  end

  # GET /reset_passwords/:id/edit
  def edit
    @user_password = UserPassword.new
  end

  # PUT /reset_passwords/:id
  def update
    @user_password = UserPassword.new(password_params)

    if @user_password.update_reset_password(@user)
      tenant = @user.active_links.first.tenant
      flash[:notice] = 'Ha actualizado su contrasenña e ingresado al sistema.'
      redirect_to dashboard_url(host: UrlTools.domain, auth_token: @user_password.user.auth_token, subdomain: tenant) and return
    else
      @user = @user_password.user
      render 'edit'
    end
  end

private
  def reset_params
    params.require(:reset_password).permit(:email)
  end

  def password_params
    params.require(:user_password).permit(:password, :password_confirmation)
  end

  def reset_search_path
    redirect_to new_reset_password_url(subdomain: false) and return if request.subdomain.present?
  end

  def find_user_or_redirect!
    unless @user = User.active.where(reset_password_token: params[:id]).first
      redirect_to new_session_url(subdomain: false), alert: 'Ingrese.' and return
    end
  end
end
