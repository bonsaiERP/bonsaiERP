# Used to access the organisation_id in the models
class OrganisationSession
  attr_reader :id, :name

  ##############
  class << self
    # Stores using de application_controller the current_user for devise
    # @param [Hash] details from the organisation
    def set(organisation)
      raise "The 'organisation' param must be a Hash" unless organisation.is_a? Hash
      @id = organisation[:id]
      @name = organisation[:name]
    end
    alias set= set

    # Initialize variables
    def destroy
      @id = @name = nil
    end

    def id
      @id
    end

  end
end
