# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'
module Models::Organisation::NewOrganisation

  extend ActiveSupport::Concern
  
  included do
    attr_readonly :organisation_id
    before_create :set_organisation, :unless => 'organisation_id.present?'
  end

  module InstanceMethods
    private
      def set_organisation
        self.organisation_id = OrganisationSession.organisation_id
      end
  end

  module ClassMethods
    def org
      where(:organisation_id => OrganisationSession.organisation_id)
    end
  end
end
