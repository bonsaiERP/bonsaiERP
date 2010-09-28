# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to access the organisation_id in the models
class OrganisationSession

  class << self
    attr_reader :organisation_id, :name
    # Stores using de application_controller the current_user for devise
    # @param [Hash] details from the organisation
    def set(organisation)
      raise "The OrganisationSession couln't be set' the param must be a hash" unless organisation.is_a? Hash
      @organisation_id = organisation[:id]
      @name = organisation[:name]
    end
    alias set= set

    # Initialize variables
    def destroy
      @organisation_id = @org_name = nil
    end

  end
end
