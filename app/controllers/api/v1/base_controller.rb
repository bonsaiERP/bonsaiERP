class Api::V1::BaseController < ActionController::Base
  before_action :authenticate_user, :set_tenant, :set_user_session

  private

    def authenticate_user
      if user_link.blank? || user_link.user.blank?
        render(text: 'Invalid token', status: 401) and return
      end
    end

    def current_user
      user_link.user
    end

    def user_link
      @user_link ||= Link.auth(api_token)
    end

    def api_token
      params[:api_token]
    end

    def page
      @page ||= params[:page].to_i > 0 ? params[:page].to_i : 1
    end

    def set_tenant
      PgTools.change_schema user_link.tenant
    end

    def set_user_session
      UserSession.user = current_user
    end
end
