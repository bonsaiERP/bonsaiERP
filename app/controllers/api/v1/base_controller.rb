class Api::V1::BaseController < ActionController::Base
  before_action :check_user
end
