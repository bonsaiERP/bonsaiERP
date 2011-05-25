# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Acts
  module Org

    def self.included(base)
      base.send(:include, ClassMethods)
      base.send(:extend, InstanceMethods)
    end

    module InstanceMethods
      def acts_as_org
        attr_readonly :organisation_id
        before_validation :set_organisation_id, :if => :new_record?
        validates_presence_of :organisation_id
      end


      def org
        where(:organisation_id => OrganisationSession.organisation_id)
      end
    end

    module ClassMethods
      def set_organisation_id
        raise "You have not set OrganisationSession" if OrganisationSession.organisation_id.nil?
        self.organisation_id = OrganisationSession.organisation_id
      end
    end
  end
end
