module OrganisationHelpers
  def currency_name
    session[:organisation][:currency_name]
  end

  def currency_symbol
    session[:organisation][:currency_symbol]
  end

  def currency_id
    session[:organisation][:currency_id]
  end

  def self.organisation_helper_methods
    [:currency_id, :currency_name, :currency_symbol]
  end
end
