# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Transaction
  module Approve
    extend ActiveSupport::Concern

    included do
      validates_length_of :credit_reference, :minimum => 3, :if => :allow_credit?
      before_save { self.cash = false if allow_credit?; true }
    end

    module InstanceMethods
      def allow_credit?
        false
      end

      def approve!
        unless state == "draft"
          false
        else
          self.state       = "approved"
          self.approver_id = UserSession.user_id
          self.approver_datetime = Time.zone.now
          self.save
        end
      end

      # Method used to approve credits
      def approve_credit(attrs)
        def self.allow_credit?; true; end # Allow validations and callbacks to work with allow_credit?

        self.credit_reference   = attrs[:credit_reference]
        self.credit_description = attrs[:credit_description]
        self.creditor_id        = UserSession.user_id
        self.credit_datetime    = Time.zone.now

        create_first_pay_plan
        self.payment_date       = pay_plans.first.payment_date

        self.save
      end

      private
        def create_first_pay_plan
          d = Date.today
          pay_plans.build(
            :payment_date => d, 
            :alert_date => d - 5.days, 
            :amount => balance,
            :interests_penalties  => 0,
            :email => true,
            :currency_id => currency_id
          )
        end

        # Creates account_ledger for the transaction
        # NOT needed anymore
        def create_account_ledger_details
          kl = self.class.to_s

          al = build_account_ledger(
            :account_id => account_id,
            :to_id => ::Account.org.find_by_original_type(kl).id,
            :currency_id => currency_id,
            :operation => 'transaction',
            :amount => total_currency,
            :reference => "#{I18n.t("#{kl.downcase}.account_ledger_reference")} #{ref_number}",
            :exchange_rate => exchange_rate
          )
          al.account_ledger_details.build(:account_id => account_id, :amount => total_currency, :state => 'con', :currency_id => currency_id )
          al.account_ledger_details.build(:account_id => al.to_id, :amount => - total_currency, :state => 'con', :currency_id => currency_id )
        end

        # Updates the balance of an account based on the amount it has
        def update_transaction_amount
          account.cur(currency_id).amount
        end
    end
  end
end
