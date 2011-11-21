# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Controllers::Authentication

  protected
  def current_user
    return false unless session[:user_id].present?
    begin
      @current_user ||= User.find(session[:user_id])
    rescue
      false
    end
  end

  def user_signed_in?
    current_user.present?
  end

  # Checks the current user and redirects to the correct path
  # if the user has created the organisation and tenant logins
  # if the user has created the organisation and not tenant => cretes tenant
  def check_logged_user
    PgTools.reset_search_path
    if current_user
      flash[:notice] = "Ingresó correctamente"
      orgs = current_user.organisations
      org_id = orgs.first.id if orgs.any?
      schema = PgTools.schema_exists? PgTools.get_schema_name(org_id)

      case
      when( orgs.any? and schema )
        set_organisation_session(current_user.organisations.first)
        PgTools.set_search_path PgTools.get_schema_name(org_id)
        user = User.find(session[:user_id])
        # Check if user is active
        if user.active?
          session[:user] = {:rol => user.rol }
          redirect_to "/dashboard"
        else
          flash[:warning] = "Usted ya no tiene permitido el acceso"
          redirect_to "/users/sign_out"
        end
      when( orgs.any? and not(schema))
        redirect_to create_tenant_organisation_path(org_id)
      else
        redirect_to "/organisations/new"
      end
    end
  end


  # Sets the session for the organisation
  def set_organisation_session(organisation)
    ret = true

    session[:organisation] = Hash[ OrganisationSession::KEYS.map {|k| [k, organisation.send(k)] } ]

    ret
  end

  def self.helpers
    [:current_user, :user_signed_in?]
  end

end
