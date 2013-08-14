module Controllers::OrganisationHelpers
  def self.included(base)
    base.instance_eval do
      helper_method :currency, :organisation_name, :organisation_id
    end
  end

  def currency
    current_organisation.currency
  end

  def organisation_name
    current_organisation.name
  end

  def organisation_id
    current_organisation.id
  end
end
