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
  helper_method Controllers::OrganisationHelpers.organisation_helper_methods

  protect_from_forgery

  ########################################
  # Callbacks
  before_filter :set_user_session, :if => :user_signed_in?
  before_filter :set_organisation_session # Must go before :check_authorization!
  before_filter :set_page, :set_tenant, :check_authorization!

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

  def current_organisation
    @organisation ||= Organisation.find_by_tenant(current_tenant)
  end
  helper_method :current_organisation

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

  def currency
    current_organisation.currency
  end
  helper_method :currency

private
  def set_page
    @page = params[:page] || 1
  end

  def current_tenant
    request.subdomain
  end

  # Uses the helper methods from devise to made them available in the models
  def set_user_session
    UserSession.user = current_user
  end

   # Checks if is set the organisation session
  def organisation?
    current_organisation.present?
  end
  helper_method :organisation?

  def set_tenant
    PgTools.change_tenant current_tenant
  end

  def set_organisation_session
    if current_organisation
      OrganisationSession.organisation = current_organisation
    end
  end
end
