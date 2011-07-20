# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Transaction
  
  extend ActiveSupport::Concern

  included do
    attr_reader :payment
    before_create :build_transaction_ledger_details, :if => :payment?
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
      return false unless active?

      account_ledger_details.each do |ac|
        ac.state = "con"
      end
      self.conciliation = true

      self.approver_id = UserSession.user_id
      set_trans_deliver
      
      res = true
      self.class.transaction do
        res = self.save
        res = res and transaction.save
        raise ActiveRecord::Rollback unless res
      end

      res
    end

    def set_trans_deliver
      if transaction.account_ledgers.pendent.count == 1
        transaction.deliver = true if transaction.balance <= 0
      end
    end

    # nulls in case that it's related to a transaction
    def null_transaction_account
      ret = true
      transaction.balance += amount - interests_penalties
      create_transaction_pay_plan if transaction.credit?

      self.class.transaction do
        ret = self.save
        ret = ret and transaction.save
        raise ActiveRecord::Rollback unless ret
      end

      ret
    end

    private
      # Creates a new pay_plan with the date of the latest nulled
      # pay_plan when a account_ledger( payment ) is nulled
      def create_transaction_pay_plan
        pp = transaction.pay_plans.paid.last

        transaction.pay_plans.build(
          :payment_date => pp.payment_date, 
          :alert_date => pp.payment_date,
          :amount => amount - interests_penalties,
          :interests_penalties  => interests_penalties,
          :email => pp.email,
          :currency_id => transaction.currency_id
        )
      end

      def build_transaction_ledger_details
        return false if exchange_rate.blank?

        puts "#{account_id} #{to_id} #{amount}"
        if account_id.present? and amount.present? and to_id.present? and account_ledger_details.empty?

          amt = amount + interests_penalties
          state = conciliation ? 'con' : 'uncon'

          account_ledger_details.build(
            :account_id => account_id, :amount => amount, 
            :currency_id => account.currency_id, :state => state
          )

          amt2 = -amount * exchange_rate

          account_ledger_details.build(
            :account_id => to_id, :amount => amt2, 
            :currency_id => account.currency_id, :state => state
          )

          if interests_penalties > 0
            Account.org.find_by_original_type('Interest')
            account_ledger_details.build(
              :account_id => to_id, :amount => interests_penalties, 
              :currency_id => account.currency_id, :state => state
            )
          end
        else
          false
        end
      end
  end
end
