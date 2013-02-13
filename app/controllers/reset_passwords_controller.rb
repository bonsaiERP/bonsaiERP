# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ResetPasswordsController < ApplicationController
  #include ActionView::Helpers::UrlHelper
  skip_before_filter :set_tenant, :check_authorization!
  before_filter :reset_search_path

  def show
    @reset_password = ResetPassword.new
  end

  def new
    @reset_password = ResetPassword.new
    if @reset_password.update_password
      redirect_to  
    end
  end

  def create
    @reset_password = ResetPassword.new(password_attributes)

    if @reset_password.reset_password
      render 'create'
    else
      flash.now[:error] = 'El email que ingreso no existe.'
      render 'new'
    end
  end

private
  def password_attributes
    params.require(:reset_password).permit(:email)
  end

  def reset_search_path
    redirect_to reset_password_url(subdomain: false) and return if request.subdomain.present?
  end
end
