module Err
  module Acts
    module Org

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_org
          include Err::Acts::Org::InstanceMethods
          before_create :set_organisation_id
        end
      end

      module InstanceMethods
        def set_organisation_id
          raise "You have not set OrganisationSession" if OrganisationSession.id.nil?
          self.organisation_id = OrganisationSession.id
        end
      end
    end
  end
end
