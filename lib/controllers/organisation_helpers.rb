module Controllers::OrganisationHelpers
  def currency_name
    session[:organisation][:currency_name]
  end

  def currency_plural
    session[:organisation][:currency_name].pluralize
  end

  def currency_complete
    "#{currency_symbol} #{currency_name}"
  end

  def currency_complete_plural
    "#{currency_symbol} #{currency_plural}"
  end

  def currency_symbol
    session[:organisation][:currency_symbol]
  end

  def currency_id
    session[:organisation][:currency_id]
  end

  def organisation_name
    session[:organisation][:name]
  end

  def organisation_id
    session[:organisation][:id]
  end

  def self.organisation_helper_methods
    [:currency_id, :currency_name, :currency_symbol, :currency_complete, :currency_complete_plural, :currency_plural, :organisation_name, :organisation_id]
  end
end
