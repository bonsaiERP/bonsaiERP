# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Organisation::NewOrganisation
  def self.included(base)
    base.send(:extend, InstanceMethods)
    base.set_organisation_callbacks
    base.send(:include, ClassMethods)
  end

  module InstanceMethods
    def set_organisation_callbacks
      before_create :set_organisation, :unless => 'organisation_id.present?'
      attr_readonly :organisation_id
    end
  end
    
  module ClassMethods

  private
    def set_organisation
      self.organisation_id = OrganisationSession.organisation_id
    end
  end
end
