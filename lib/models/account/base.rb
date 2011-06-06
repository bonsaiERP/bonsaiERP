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
        before_save :set_account_data

        has_one :account, :as => :accountable, :autosave => true
      end
    end

    module ClassMethods
      private
      # Method that create an account
      def set_account_data
        self.build_account(
          :currency_id => self.currency_id || OrganisationSession.currency_id)
      end
    end
  end
end
