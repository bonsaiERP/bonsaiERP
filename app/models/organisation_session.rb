# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to access the organisation_id in the models
class OrganisationSession

  class << self
    attr_reader :organisation_id, :name, :currency_id
    # Stores using de application_controller the current_user for devise
    # @param [Hash] details from the organisation
    def set(organisation)
      raise "The OrganisationSession couln't be set' the param must be a hash" unless organisation.is_a? Hash
      @organisation_id = organisation[:id]
      @name = organisation[:name]
      @currency_id = organisation[:currency_id]
    end
    alias set= set

    # Initialize variables
    def destroy
      @organisation_id = @org_name = @currency_id = nil
    end

    #def organisation_id
    #  @organisation_id
    #end

    #def currency_id
    #  @currency_id
    #end

    #def name
    #  @name
    #end

    # Returns the currencies of the current organisation
    def currencies
      o = Organisation.find(@organisation_id)
      [o.currency]+ o.currencies
    end

  end
end
