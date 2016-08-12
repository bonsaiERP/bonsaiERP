# author: Boris Barroso
# email: boriscyber@gmail.com
class ApplicationController < ActionController::Base
  layout lambda { |c|
    case
    when (c.request.xhr? or params[:xhr]) then false
    when params[:print].present?          then 'print'
    else
     'application'
    end
  }

  include Controllers::Authentication
  include Controllers::Authorization
  include Controllers::RescueFrom

  protect_from_forgery

  ########################################
  # Callbacks
  before_action :set_user_session, if: :user_signed_in?
  before_action :set_organisation_session # Must go before :check_authorization!
  before_action :set_page, :set_tenant, :check_authorization!
  before_action :set_locale, if: :user_signed_in?

  # especial redirect for ajax requests
  def redirect_ajax(klass, options = {})
    if request.xhr?
      serialized_xhr_response klass, options
    else
      url = options[:url] || klass

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
    @organisation ||= Organisation.find_by(tenant: current_tenant)
  end
  helper_method :current_organisation

  def current_link
    @link ||= current_user.links.org_links(current_organisation.id).first!
  end
  helper_method :current_link

  def user_with_role
    @user_with_role ||= UserWithRole.new(current_user, current_organisation)
  end
  helper_method :user_with_role

  def tenant
    @tenant ||= current_organisation.try(:tenant)
  end
  helper_method :tenant

  def path_sub(path, extras = {})
    if USE_SUBDOMAIN
      send(path, {host: DOMAIN, subdomain: session[:tenant]}.merge(extras))
    else
      extras.delete(:subdomain)
      send(path, extras)
    end
  end

  private

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

    delegate :name, :currency, to: :current_organisation, prefix: :organisation, allow_nil: true
    alias_method :currency, :organisation_currency
    helper_method :currency, :organisation_name

    def set_page
      @page = params[:page] || 1
    end

    def current_tenant
      session[:tenant]
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
      PgTools.change_schema current_tenant
    end

    def set_organisation_session
      if current_organisation
        OrganisationSession.organisation = current_organisation
      end
    end

    def search_term
      params[:search] || params[:q] || params[:term]
    end

    def serialized_xhr_response(klass, options)
      r = ControllerServiceSerializer.new(klass)
      options.merge(methods: [:destroyed?])  if request.delete?

      render json: r.to_json(only: options[:only], except: options[:except], methods: options[:methods])
    end

    def set_locale
      I18n.locale = current_user.locale || :es
    end

end

class MasterAccountError < StandardError; end
