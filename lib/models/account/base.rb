# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module  Models::Account
  module Base
    
    def self.included(base)
      base.send(:extend, InstanceMethods)
      base.set_account_settings
      base.send(:include, ClassMethods)
    end

    module InstanceMethods
      def set_account_settings
        before_save :select_account_type_and_create

        has_one :account, :as => :accountable, :autosave => true
        attr_readonly :initial_amount
      end
    end

    module ClassMethods

      private
      def create_new_account
        self.build_account(:currency_id => OrganisationSession.currency_id,
                          :account_type_id => AccountType.org.scoped_by_account_number(self.class.to_s).first.id )
      end

      # Selects the methods neccessary accordiny the class
      def select_account_type_and_create

        case self.class.to_s
          when "Bank", "Cash" then self.extend Models::Account::MoneyAccount
          when "ItemService" then self.extend Models::Account::ServiceAccount
        end

        create_new_account
      end
    end
  end
end
