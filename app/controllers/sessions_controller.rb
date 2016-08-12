# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  #before_action :redirect_www
  skip_before_action :set_tenant, :check_authorization!
  before_action :check_logged_in, only: %i(new create)
  layout "sessions"

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)

    case
    when @session.authenticate?
      session[:user_id] = @session.user_id
      session[:tenant] = @session.tenant

      flash[:notice] = t("views.sessions.flash_login")
      redirect_to( path_sub(:home_url)) and return
    else
      flash.now[:error] = t("views.sessions.flash_login_error")

      render :new
    end
  end

  def destroy
    reset_session

    redirect_to path_sub(:login_url, subdomain: "app"), notice: t("views.sessions.flash_login")
  end


  private

    def check_logged_in
      if session[:tenant] && session[:user_id] && u = User.active.find(session[:user_id])
        redirect_to path_sub(:home_url), notice: t("views.sessions.flash_login")
      else
        reset_session
      end
    rescue
      reset_session
      redirect_to path_sub(:login_url), error: t("views.sessions.flash_no_user") and return
    end

    def session_params
      params.require(:session).permit(:email, :password)
    end

    def redirect_www
      if request.subdomain === "www"
        Rails.logger.info "SUBDOMAIN: #{ request.subdomain }"
        redirect_to "http://bonsaierp.com" and return
      end
    end
end
