# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  before_filter :check_authorization!

  # GET /dashboard
  def index
    @currency_rates = CurrencyRate.current_hash
  end

  # GET /config
  def configuration
    @links = Organisation.find( OrganisationSession.organisation_id).links.includes(:user)
  end

end
