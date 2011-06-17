# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::AccountLedger
  module Money

    def self.included(base)
      base.send(:extend, InstanceMethods)
      base.set_money_setting

      base.class_eval do
        def money?
          false
        end
      end
    end

    module InstanceMethods
      def set_money_setting
        before_create :create_ledger_details, :if => :money?

        validates_presence_of :account_id, :to_id, :if => :money?
        validates_numericality_of :amount, :if => :money?
      end

      def new_money(params = {})
        ac = AccountLedger.new(params)
        ac.extend Models::AccountLedger::Money::ClassMethods
        
        ac
      end
    end

    module ClassMethods
      def money?
        true
      end

      private

      def create_ledger_details
        puts "creating details"
        amt = amount_operation
        account_ledger_details.build(:account_id => account_id, :amount => amt, :currency_id => account.currency_id)
        account_ledger_details.build(:account_id => to_id, :amount => -amt, :currency_id => account.currency_id)
      end

      def amount_operation
        case operation
        when "in", "tran" then amount
        when "out"        then -1 * amount
        end
      end
    end

  end
end
