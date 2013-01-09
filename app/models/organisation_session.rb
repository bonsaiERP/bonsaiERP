# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to access the organisation_id in the models
class OrganisationSession
  class << self
    attr_reader :organisation
    delegate :name, :currency, :tenant, :emamil, :address, to: :organisation


    # Stores using de application_controller the current_user for devise
    # @param [Hash] details from the organisation
    def set(org)
      raise "The OrganisationSession couln't be set' expected Organisation" unless org.is_a? Organisation
      @organisation = org
    end
    alias set= set

    def organisation_id
      @organisation.id
    end
  end
end
