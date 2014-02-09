# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ResetPasswordsController < ApplicationController
  layout 'sessions'

  skip_before_filter :set_tenant, :check_authorization!
  before_filter :find_user_or_redirect!, only: [:edit, :update]

  def index
  end

  # GET /reset_passwords/new
  def new
    @reset_password = ResetPasswordEmail.new
  end

  # POST /reset_passwords
  def create
    @reset_password = ResetPasswordEmail.new(reset_params)

    if @reset_password.reset_password
      redirect_to reset_passwords_path
    else
      flash.now[:error] = 'El email que ingreso no existe.'

      render :new
    end
  end

  # GET /reset_passwords/:id/edit
  def edit
    @reset_password = ResetPassword.new
  end

  # PUT /reset_passwords/:id
  def update
    @reset_password = ResetPassword.new(password_params)

    if @reset_password.update_password
      flash[:notice] = 'Ha actualizado su contraseña por favor ingrese al sistema.'

      redirect_to login_path(host: DOMAIN, subdomain: 'app')
    else

      render :edit
    end
  end

  private

    def reset_params
      params.require(:reset_password_email).permit(:email)
    end

    def password_params
      params.require(:reset_password)
      .permit(:password, :password_confirmation)
      .merge(user: user)
    end

    def find_user_or_redirect!
      unless @user = User.active.where(reset_password_token: params[:id]).first
        redirect_to new_session_url(subdomain: false), alert: 'Ingrese.' and return
      end
    end

    def user
      @user ||= User.active
      .where(reset_password_token: params[:id])
      .where("reset_password_sent_at > ?", time).first
    end

    def time
      1.hour.ago
    end
end
