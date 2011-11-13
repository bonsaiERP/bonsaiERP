# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Account
  module Base
    
    extend ActiveSupport::Concern

    included do
      before_create :set_account_name
      before_create :create_new_account
    end

    module ClassMethods
    end

    module InstanceMethods
      def account_cur
        accounts.find_by_currency_id(currency_id)
      end

      private
      def create_new_account
        currency_id ||= OrganisationSession.currency_id

        self.accounts.build(
          :currency_id => currency_id,
          :account_type_id => AccountType.find_by_account_number(self.class.to_s).id,
        ) {|a|
          a.original_type = self.class.to_s
        }
      end

      def set_account_name
        ac = self.account_cur
        ac.name = self.to_s
      end
    end
  end
end
