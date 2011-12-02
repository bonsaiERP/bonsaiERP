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
    PgTools.reset_search_path
    @org = Organisation.find(OrganisationSession.organisation_id)
  end

end
