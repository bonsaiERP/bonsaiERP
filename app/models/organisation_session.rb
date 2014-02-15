# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to access the organisation_id in the models
class OrganisationSession
  class << self
    attr_reader :organisation
    delegate :id, :name, :currency, :tenant, :emamil, :address, :inventory_active?, :inventory?,
      to: :organisation, allow_nil: true


    # Stores using de application_controller the current_user for devise
    # @param [Hash] details from the organisation
    def organisation=(org)
      raise "The OrganisationSession couln't be set' expected Organisation" unless org.is_a? Organisation
      @organisation = org
    end
  end
end
