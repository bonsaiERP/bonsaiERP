# Called for many model callbacks
class OrganisationCallbacks

  def self.before_create(klass)
    raise "The OrganisationSession.organisation_id has not been set" if OrganisationSession.organisation_id.nil?
    klass.set_organisation_id = OrganisationSession.organisation_id
  end

end
