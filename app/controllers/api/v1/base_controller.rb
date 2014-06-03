class Api::V1::BaseController < ActionController::Base
  before_action :authenticate_user

  private

    def authenticate_user
      if user_link.blank? || user_link.user.blank?
        render(text: 'Invalid token', status: 401) and return
      end
    end

    def current_user
      user_link.current_user
    end

    def user_link
      @user_link ||= Link.auth(api_token)
    end

    def api_token
      params[:api_token]
    end

end
