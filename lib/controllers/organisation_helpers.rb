module Controllers::OrganisationHelpers
  def currency_complete
    "#{currency_symbol} #{currency_name}"
  end

  def currency_complete_plural
    "#{currency_symbol} #{currency_plural}"
  end

  def currency
    current_organisation.currency
  end

  def organisation_name
    current_organisation.name
  end

  def organisation_id
    session[:organisation][:id]
  end

  def self.organisation_helper_methods
    [:currency_complete, :currency_complete_plural, :currency_id, :currency_name, 
     :currency_code, :currency_symbol, :currency_plural, :organisation_name, :organisation_id]
  end
end
