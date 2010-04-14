# Used to access the authenticated user in the models
class OrganisationSession
  attr_accessor :organisation
  # Stores using de application_controller the current_user for devise
  def self.organisation=(session)
    @organisation = session
  end

  def self.organisation
    @organisation
  end
end
