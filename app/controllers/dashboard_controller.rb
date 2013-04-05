# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  # GET /dashboard
  def index
    @dashboard = DashboardPresenter.new(view_context)
  end
end
