# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'
module Acts
  module Org
    extend ActiveSupport::Concern

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

        unless OrganisationSession.organisation_id.blank?
          self.organisation_id = OrganisationSession.organisation_id
        else
          self.errors[:base] << I18n.t("organisation_session.errors.organisation_id")
          false
        end
      end
    end
  end
end
