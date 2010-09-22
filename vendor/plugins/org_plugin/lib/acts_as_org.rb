module Acts
  module Org

    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def acts_as_org
        attr_readonly :organisation_id
        before_validation :set_organisation_id, :if => :new_record?
        validates_presence_of :organisation_id
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
