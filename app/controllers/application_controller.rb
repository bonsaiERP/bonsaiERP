# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ApplicationController < ActionController::Base
  layout lambda{ |c| c.request.xhr? ? false : "application" }

  protect_from_forgery
  before_filter :set_user_session, :if => :user_signed_in?
  before_filter :set_organisation, :if => :organisation?
  before_filter :set_page

  before_filter :destroy_organisation_session!, :unless => :user_signed_in?

  include OrganisationHelpers
  helper_method OrganisationHelpers.organisation_helper_methods

#
#  # Used to redirect after a user has signed_in
  #def after_sign_in_path_for(resource)
  #  debugger
  #  s=0
  #  if resource.is_a?(User)
  #    new_organisation_url
  #  else
  #    super
  #  end
  #end
#
  # Adds an error with format to display
  # @param ActiveRecord::Base (model)
  def add_flash_error(model)
    flash[:error] = I18n.t("flash.error") if flash[:error].nil?
      
    unless model.errors.base.empty?
      flash[:error] << "<ul>"
      model.errors[:base].map{|e| flash[:error] << %Q(<li>#{e}</li>) }
      flash[:error] << "<ul>"
    end
  end

  
  def after_logout_path_for(resource)
    debugger
    s=0
  end

    # especial redirect for ajax requests
  def redirect_ajax(klass, options = {})
    url = options[:url] || klass
    if request.xhr?
      if request.delete?
        render :json => klass.attributes.merge(:destroyed => klass.destroyed?)
      else
        render :json => klass
      end
    else
      redirect_to url, options
    end
  end

private

  def set_page
    @page = params[:page] || 1
  end

  # Sets the session for the organisation
  def set_organisation_session(organisation)
    session[:organisation] = {
      :id => organisation.id, :name => organisation.name, 
      :currency_id => organisation.currency_id, :currency_name => organisation.currency_name,
      :currency_symbol => organisation.currency_symbol }
    set_organisation
  end

  def destroy_organisation_session!
    session[:organisation] = {}
    OrganisationSession.destroy
  end

  # Uses the helper methods from devise to made them available in the models
  def set_user_session
    UserSession.current_user = current_user
  end

   # Checks if is set the organisation session
  # @return [True, False]
  def organisation?
    session[:organisation] and session[:organisation].size > 0
  end

  # Sets the organisation_id to help to set in the models
  def set_organisation
    raise "You must set the organisation" if session[:organisation].blank?
    OrganisationSession.set session[:organisation]
  end

  def check_organisation
    redirect_to organisations_path if session[:organisation][:id].nil?
  end

  # Checks if the currency has been set
  def check_currency_set
    org = Organisation.find(OrganisationSession.organisation_id)
    unless CurrencyRate.current?(org)
      flash[:warning] = "Debe actualizar los tipos de cambio."
      redirect_to new_currency_rate_path
    end
  end
  
end

