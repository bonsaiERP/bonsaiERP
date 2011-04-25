# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  before_filter :authenticate_user!

  # GET /dashboard
  def index
    @currency_rates = CurrencyRate.current_hash
  end

  # GET /config
  def configuration
    @links = Organisation.find( OrganisationSession.organisation_id).links.includes(:user)
  end

private
  def set_organisation
    @organisation = Organisation.find(current_user.links.first.organisation_id)
    set_organisation_session(@organisation)
  end
end
