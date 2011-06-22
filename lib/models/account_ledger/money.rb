# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger
  module Money

    extend ActiveSupport::Concern

    included do
      before_validation :create_ledger_details, :if => :new_money?

      validates_presence_of :account_id, :to_id, :if => :money?
      validates_numericality_of :amount, :if => :money?
    end

    module ClassMethods

      def new_money(params = {})
        ac = AccountLedger.new(params)
        params.symbolize_keys.assert_valid_keys( :operation, :account_id, :to_id, :amount, :reference )
        def ac.money?; true; end
        ac.conciliation = false
        
        ac
      end
    end

    module InstanceMethods
      def new_money?
        new_record? and money?
      end

      def money?; false; end

      # Makes the conciliation to update accounts
      def conciliate_account
        account_ledger_details.each do |ac|
          ac.state = "con"
        end

        self.save
      end

      private

      def create_ledger_details
        amt = amount_operation
        if account_id.present? and amount.present? and to_id.present?
          account_ledger_details.build(:account_id => account_id, :amount => amt, :currency_id => account.currency_id, :state => 'uncon')
          account_ledger_details.build(:account_id => to_id, :amount => -amt, :currency_id => account.currency_id, :state => 'uncon')
        end
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
