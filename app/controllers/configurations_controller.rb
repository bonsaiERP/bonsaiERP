class ConfigurationsController < ApplicationController
  def index
    @users = User.order(:id).all
    @org   = current_organisation
  end
end
