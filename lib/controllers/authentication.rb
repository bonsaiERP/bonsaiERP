# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Controllers::Authentication

  protected
  def current_user
    return false unless session[:user_id].present?
    @current_user ||= User.find(session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  # Checks the current user and redirects to the correct path
  # if the user has created the organisation and tenant logins
  # if the user has created the organisation and not tenant => cretes tenant
  def check_logged_user
    if current_user
      flash[:notice] = "Ingresó correctamente"
      orgs = current_user.organisations
      org_id = orgs.first.id if orgs.any?

      case
      when( orgs.any? and check_organisation_tenant(org_id) )
        set_organisation_session(current_user.organisations.first)
        session[:user] = {:rol => current_user.link.rol }
        redirect_to "/dashboard"
      when( orgs.any? and not(check_organisation_tenant(org_id) ) )
        redirect_to create_tenant_organisation_path(org_id)
      else
        redirect_to "/organisations/new"
      end
    end
  end

  def check_organisation_tenant(organisation_id)
    !!PgTools.set_search_path( organisation_id )
  end

  # Sets the session for the organisation
  def set_organisation_session(organisation)
    ret = true

    session[:organisation] = Hash[ OrganisationSession::KEYS.map {|k| [k, organisation.send(k)] } ]
    set_organisation

    ret
  end

  def self.helpers
    [:current_user, :user_signed_in?]
  end

end
