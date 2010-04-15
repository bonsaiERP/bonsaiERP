# Used to access the organisation_id in the models
class OrganisationSession
  attr_accessor :organisation_id
  # Stores using de application_controller the current_user for devise
  def self.organisation_id=(organisation_id)
    @organisation_id = organisation_id
  end

  def self.organisation_id
    @organisation_id
  end
end
