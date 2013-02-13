# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ResetPasswordsController < ApplicationController
  #include ActionView::Helpers::UrlHelper
  skip_before_filter :set_tenant, :check_authorization!
  before_filter :reset_search_path
  before_filter :check_user_reset_token!, only: [:edit, :update]

  # GET /reset_passwords/new
  def new
    @reset_password = ResetPassword.new
    if @reset_password.update_password
      redirect_to  
    end
  end

  # POST /reset_passwords
  def create
    @reset_password = ResetPassword.new(password_attributes)

    if @reset_password.reset_password
      render 'create'
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
  end

private
  def password_attributes
    params.require(:reset_password).permit(:email)
  end

  def reset_search_path
    redirect_to reset_password_url(subdomain: false) and return if request.subdomain.present?
  end

  def check_user_reset_token!
    params
  end
end
