module Controllers::Authentication

  protected
  def current_user
    return false unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  # Checks the current user and redirects to the correct path
  def check_logged_user
    if current_user
      flash[:notice] = "Ingreso correctamente."
      if current_user.organisations.any?
        set_organisation_session(current_user.organisations.first)
        session[:user] = {:rol => current_user.link.rol }
        redirect_to "/dashboard"
      else
        redirect_to "/organisations/new"
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

  # Sets the session for the organisation
  def set_organisation_session(organisation)
    ret = true
    # Create base_accounts if needed
    ret = organisation.create_base_accounts unless organisation.base_accounts?

    session[:organisation] = Hash[ OrganisationSession::KEYS.map {|k| [k, organisation.send(k)] } ]
    set_organisation

    ret
  end

  def self.helpers
    [:current_user, :user_signed_in?]
  end

end
