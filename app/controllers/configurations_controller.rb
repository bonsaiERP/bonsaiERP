class ConfigurationsController < ApplicationController
  def index
    @users = current_organisation.users
    @org   = current_organisation
  end
end
