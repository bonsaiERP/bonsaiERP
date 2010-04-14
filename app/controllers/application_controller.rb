class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_user_session
  before_filter :set_organisation

  # Adds an error with format to display
  #   @param ActiveRecord::Base (model)
  def add_flash_error(model)
    flash[:error] = I18n.t("flash.error") if flash[:error].nil?
      
    unless model.errors.base.empty?
      flash[:error] << "<ul>"
      model.errors[:base].map{|e| flash[:error] << %Q(<li>#{e}</li>) }
      flash[:error] << "<ul>"
    end
  end

  private
  # Uses the helper methods from devise to made them available in the models
  def set_user_session
    UserSession.current_user = current_user
  end

  # Sets the organisation_id to help to set in the models
  def set_organisation
    unless session[:organisation]
      OrganisationSession.organisation = session[:organisation]
    end
  end

end
