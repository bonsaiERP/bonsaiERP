# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module  Models::Account
  module ServiceAccount
    extend ActiveSupport::Concern

    included do
      with_options :if => :service? do |serv|
        serv.before_save :create_new_account, :if => :new_record?
        serv.before_save :set_account_name
      end

      has_one :account, :as => :accountable, :autosave => true
    end

    module ClassMethods
    end

    module InstanceMethods

      private

      def create_new_account
        self.build_account(
          :currency_id => OrganisationSession.currency_id,
          :account_type_id => AccountType.org.find_by_account_number(self.class.to_s).id,
        ) {|a|
          a.organisation_id = OrganisationSession.organisation_id
          a.original_type = self.class.to_s
          a.name = self.to_s
        }
      end

      def set_account_name
        account.name = self.to_s
      end

    end

  end
end

