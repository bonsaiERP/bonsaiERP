# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ApplicationController < ActionController::Base
  layout lambda{ |c| (c.request.xhr? or params[:xhr]) ? false : "application" }

  protect_from_forgery
  before_filter :set_user_session, :if => :user_signed_in?
  before_filter :set_organisation, :if => :organisation?
  before_filter :set_page

  before_filter :destroy_organisation_session!, :unless => :user_signed_in?

  include Authorization
  include OrganisationHelpers  

  helper_method OrganisationHelpers.organisation_helper_methods


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

  def after_inactive_sing_up_path_for(resource)
    flash[:notice] = "Se le ha enviado un email con instruciones a #{resource.email}, para que confirme su registro"
    "/users/sign_in"
  end

  #def after_sign_in_path_for(resource)
  #  if current_user.organisations.any?
  #    destroy_organisation_session!
  #    set_organisation_session(current_user.organisations.first)
  #    redirect_to dashboard_url
  #  end
  #end
  
  def after_logout_path_for(resource)
  end

    # especial redirect for ajax requests
  def redirect_ajax(klass, options = {})
    url = options[:url] || klass
    if request.xhr?
      if request.delete?
        render :json => klass.attributes.merge(:destroyed => klass.destroyed?, :errors => klass.errors[:base].join(", "))
      else
        render :json => klass
      end
    else
      redirect_to url, options
    end
  end

protected

  # Sets the session for the organisation
  def set_organisation_session(organisation)
    session[:organisation] = Hash[ OrganisationSession::KEYS.map {|k| [k, organisation.send(k)] } ]
    set_organisation
  end

private

  def set_page
    @page = params[:page] || 1
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
    session[:organisation] and session[:organisation].any?
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

