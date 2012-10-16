# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  before_filter :check_authorization!

  # GET /dashboard
  def index
  end

  # GET /config
  def configuration
    @users = User.order(:id).all
    @org   = current_organisation
  end

end
