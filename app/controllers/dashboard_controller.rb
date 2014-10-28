# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  include Controllers::DateRange

  #before_filter :set_date_range
  skip_before_action :check_authorization!
  before_action :check_user_session

  # GET /home

  # GET /dashboard
  def index
    #@dashboard = DashboardPresenter.new(view_context, @date_range)
  end

  private

    def check_user_session
      unless current_user
        redirect_to logout_path and return
      end
    end
end
