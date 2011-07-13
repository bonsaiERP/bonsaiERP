# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Transaction
  
  extend ActiveSupport::Concern

  included do
    attr_reader :payment
    before_validation :build_transaction_ledger_details, :if => :payment?
  end

  module InstanceMethods
    def set_payment(val = true)
      @payment = val
    end

    def payment?
      @payment === true
    end

    # Returns the amount of money depeding the transaction currency
    def amount_payment
      amount
    end

    def conciliate_transaction_account
      trans = self.transaction
      return false unless active?

      account_ledger_details.each do |ac|
        ac.state = "con"
      end
      self.conciliation = true

      self.approver_id = UserSession.user_id
      set_trans_deliver(trans)
      
      res = true
      self.class.transaction do
        res = self.save
        res = res and trans.save
        raise ActiveRecord::Rollback unless res
      end
      res
    end

    def set_trans_deliver(trans)
      trans.deliver = true if trans.balance <= 0# Review only for trans
    end

    #def new_payment
    #  def self.payment?; true; end # Set to activate callbacks

    #  "hola"
    #end

    private
      def build_transaction_ledger_details
        return false if exchange_rate.blank?
        if account_id.present? and amount.present? and to_id.present? and account_ledger_details.empty?

          amt = amount + interests_penalties

          account_ledger_details.build(
            :account_id => account_id, :amount => amount, 
            :currency_id => account.currency_id, :state => 'uncon'
          )

          amt2 = -amount * exchange_rate

          account_ledger_details.build(
            :account_id => to_id, :amount => amt2, 
            :currency_id => account.currency_id, :state => 'uncon'
          )

          if interests_penalties > 0
            Account.org.find_by_original_type('Interest')
            account_ledger_details.build(
              :account_id => to_id, :amount => interests_penalties, 
              :currency_id => account.currency_id, :state => 'uncon'
            )
          end
        end
      end
  end
end
