# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  include Controllers::DateRange

  before_filter :set_date_range

  # GET /home

  # GET /dashboard
  def index
    @dashboard = DashboardPresenter.new(view_context, @date_range)
  end
end
