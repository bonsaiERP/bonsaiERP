# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Transaction
  
  extend ActiveSupport::Concern

  included do
    attr_reader :payment

    with_options :if => :payment? do |al|
      al.before_create :set_ledger_data
      al.before_create :valid_trans_amount
      al.after_update  :check_transaction_conciliation
    end
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

    # nulls in case that it's related to a transaction
    def null_transaction_account
      ret = true
      transaction.balance += (amount_currency).abs

      create_transaction_pay_plan if transaction.credit?

      self.class.transaction do
        ret = self.save

        transaction.state = "approved" if transaction.paid?
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

    def get_amount_sign
      case transaction.class.to_s
      when "Income" then 1
      when "Buy", "Expense" then -1
      end
    end

    def set_ledger_data
      set_amount
      valid_contact_amount
    end

    def set_amount
      case transaction.class.to_s
      when "Buy"
        self.amount = -amount
      end
    end

    def valid_trans_amount
      if transaction.is_a?(Income) and account.accountable_type === 'Contact'
        if amount.abs > -account.amount
          self.errors[:amount] = I18n.t("errors.messages.payment.account_amount")
          return false
        end
      elsif transaction.is_a?(Buy) and account.accountable_type === 'MoneyStore'
        if amount.abs > account.amount
          self.errors[:amount] = I18n.t("errors.messages.payment.account_amount")
          return false
        end
      end
    end

  end
end
