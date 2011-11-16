# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ApplicationController < ActionController::Base
  layout lambda{ |c| 
    if (c.request.xhr? or params[:xhr])
      false 
    elsif params[:print].present?
      "print"
    else
     "application" 
    end
  }

  include Controllers::Authentication
  helper_method Controllers::Authentication.helpers

  include Controllers::Authorization
  include Controllers::OrganisationHelpers 
  helper_method Controllers::OrganisationHelpers.organisation_helper_methods

  protect_from_forgery
  before_filter :set_user_session, :if => :user_signed_in?
  before_filter :set_page
  before_filter :set_organisation, :if => :organisation?

  #before_filter :destroy_organisation_session!, :unless => :user_signed_in?

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

  # especial redirect for ajax requests
  def redirect_ajax(klass, options = {})
    url = options[:url] || klass
    if request.xhr?
      if request.delete?
        render :json => klass.to_json(:methods => [ :destroyed?, :errors ])
      else
        render :json => klass
      end
    else
      if request.delete?
        set_redirect_options(klass, options) 
        url = "/#{klass.class.to_s.downcase.pluralize}" unless url.is_a?(String)
      end

      redirect_to url
    end
  end

  # Add some helper methods to the controllers
  def help
    Helper.instance
  end

protected
  # Creates the flash messages when an item is deleted
  def set_redirect_options(klass, options)
    if klass.destroyed?
      case
      when (options[:notice].blank? and flash[:notice].blank?)
        flash[:notice] = "Se ha eliminado el registro correctamente."
      when (options[:notice] and flash[:notice].blank?)
        flash[:notice] = options[:notice]
      end
    else
      if flash[:error].blank? and klass.errors.any?
        txt = options[:error] ? options[:error] : "No se pudo borrar el registro: #{klass.errors[:base].join(", ")}." 
        flash[:error] = txt
      elsif flash[:error].blank?
        txt = options[:error] ? options[:error] : "No se pudo borrar el registro."
        flash[:error] = txt
      end
    end
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
  helper_method :organisation?

  # Sets the organisation_id to help to set in the models and the search path
  def set_organisation
    raise "You must set the organisation" if session[:organisation].blank?
    OrganisationSession.set session[:organisation]
    begin
      PgTools.set_search_path PgTools.get_schema_name(session[:organisation][:id])
    rescue
      session[:organisation] = nil
      session[:user_id] = nil
      redirect_to "/users/sign_out"
    end
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
