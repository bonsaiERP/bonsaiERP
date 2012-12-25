# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Used to access the organisation_id in the models
class OrganisationSession

  KEYS = [:id, :name, :currency_id, :currency_name, :currency_symbol, :due_date]

  class << self
    attr_reader :organisation_id, :name, :currency_id
    # Stores using de application_controller the current_user for devise
    # @param [Hash] details from the organisation
    def set(organisation)
      raise "The OrganisationSession couln't be set' expected Organisation" unless organisation.is_a? Organisation
      @organisation = organisation
    end
    alias set= set

    def organisation_id
      @organisation.id
    end

    [:currency_id, :name, :email].each do |meth|
      define_method meth do
        @organisation.send(meth)
      end
    end

  end
end
