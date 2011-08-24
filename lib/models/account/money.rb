# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module  Models::Account
  module Money

    extend ActiveSupport::Concern

    included do
      before_create :create_new_account
      before_save :set_account_name, :unless => :new_record?
    end

    module ClassMethods
    end

    module InstanceMethods
      def account_cur
        accounts.select{|v| v.currency_id === currency_id}.first
      end

      private
      def create_new_account
        self.build_account(
          :currency_id => currency_id,
          :account_type_id => AccountType.org.find_by_account_number(self.class.to_s).id,
        ) {|a|
          a.organisation_id = OrganisationSession.organisation_id
          a.original_type = self.class.to_s
          a.amount = self.amount
          a.name = self.to_s
        }
      end

      def set_account_name
        ac = self.account_cur
        ac.name = self.to_s
      end
    end

  end
end
