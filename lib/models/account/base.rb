# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Account
  module Base
    
    extend ActiveSupport::Concern

    included do
      before_save :select_account_type_and_create, :if => :new_record?
      before_save { self.account.name = self.to_s }
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
        }
      end

      # Selects the methods neccessary accordiny the class
      def select_account_type_and_create
        case self.class.to_s
          when "Bank", "Cash" 
            self.extend Models::Account::MoneyAccount
        end

        create_new_account
      end
    end
  end
end
