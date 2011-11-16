# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Account
  module Contact
    
    extend ActiveSupport::Concern

    included do
      attr_accessor :currency_id

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
        currency_id ||= OrganisationSession.currency_id

        self.accounts.build(
          :currency_id => currency_id,
          :account_type_id => AccountType.find_by_account_number(self.class.to_s).id
        ) {|a|
          a.original_type = self.class.to_s
          a.name = self.to_s
        }
      end

      def set_account_name
        if matchcode_changed?
          begin
            accounts.update_all(:name => matchcode )
          rescue
            return false
          end
        end
      end
    end
  end
end

