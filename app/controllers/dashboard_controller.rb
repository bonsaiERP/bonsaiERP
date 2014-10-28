# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  include Controllers::DateRange

  before_filter :set_date_range, only: [:index]

  skip_before_action :check_authorization!, only: [:home]
  before_action :check_user_session

  # GET /home
  def home
  end

  # GET /dashboard
  def index
    @dashboard = DashboardPresenter.new(view_context, @date_range)
  end

  private

    def check_user_session
      unless current_user
        redirect_to logout_path and return
      end
    end
end
