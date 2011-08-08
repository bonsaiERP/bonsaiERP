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

  def after_sign_in_path_for(resource)
    if !current_user
      "/users/sign_in"
    elsif current_user.organisations.any?
      set_organisation_session(current_user.organisations.first)
      session[:user] = {:rol => current_user.link.rol }
      "/dashboard"
    elsif current_user.organisations.empty?
      new_organisation_path
    end
  end

  def after_sign_out_path_for(resource)
    "/users/sign_in"
  end

    # especial redirect for ajax requests
  def redirect_ajax(klass, options = {})
    url = options[:url] || klass
    if request.xhr?
      if request.delete?
        render :json => klass.to_json(:methods => [ :destroyed?, :errors ])
        #.attributes.merge(:destroyed => klass.destroyed?, :errors => klass.errors[:base].join(", "))
      else
        render :json => klass
      end
    else
      set_redirect_options(klass, options) if request.delete?
      redirect_to url
    end
  end

protected
  # Creates the flash messages when an item is deleted
  def set_redirect_options(klass, options)
    if klass.destroyed?
      case
      when (options[:notice].blank? and flash[:notice].blank?)
        flash[:notice] = "Se ha eliminado el registro correctamente"
      when (options[:notice] and flash[:notice].blank?)
        flash[:notice] = options[:notice]
      end
    else
      if flash[:error].blank? and klass.errors.any?
        txt = options[:error] ? options[:error] : "No se pudo borrar el registro: #{klass.errors[:base].join(", ")}" 
        flash[:error] = txt
      elsif flash[:error].blank?
        txt = options[:error] ? options[:error] : "No se pudo borrar el registro"
        flash[:error] = txt
      end
    end
  end

  # Sets the session for the organisation
  def set_organisation_session(organisation)
    ret = true
    # Create base_accounts if needed
    ret = organisation.create_base_accounts unless organisation.base_accounts?

    session[:organisation] = Hash[ OrganisationSession::KEYS.map {|k| [k, organisation.send(k)] } ]
    set_organisation

    ret
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

