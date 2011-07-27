# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger
  module Money

    extend ActiveSupport::Concern

    included do
      before_validation :set_exchange_rate, :if => :new_money?
      before_validation :create_ledger_details, :if => :new_money?
      before_create     :add_description, :if => :money?
      before_create     :set_amount, :if => :money?

      validates_presence_of :account_id, :to_id, :if => :money?
      validate :valid_money_accounts, :if => :new_money?
    end

    module ClassMethods

      def new_money(params = {})
        params.transform_date_parameters!("date")
        params.symbolize_keys.assert_valid_keys( :operation, :account_id, :to_id, :amount, :reference, :date, :exchange_rate, :description )

        ac = AccountLedger.new(params)
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

      private

        # Adds the description
        def add_description
          case operation
          when "in"    then self.description = "Ingreso por #{to}"
          when "out"  then self.description = "Egreso para #{to}"
          when "trans" then self.description = "Transferencia de #{account} a #{to} con tipo de cambio 1 #{account.currency_symbol} = #{number_with_precision exchange_rate} #{to.currency_symbol}"
          end
        end

        def create_ledger_details
          if account_id.present? and amount.present? and to_id.present?
            amt = amount_operation

            account_ledger_details.build(
              :account_id => account_id, :amount => amt, 
              :currency_id => account.currency_id, :state => 'uncon'
            )

            amt2 = -amt * exchange_rate
            account_ledger_details.build(
              :account_id => to_id, :amount => amt2, 
              :currency_id => account.currency_id, :state => 'uncon'
            )
          end
        end

        def set_exchange_rate
          if ['in', 'out'].include?(operation)
            self.exchange_rate = 1
          else
            if account and to
              self.exchange_rate = 1 if account_currency_id == to_currency_id
            end
          end
        end

        # defines the amount based on the oeration
        def amount_operation
          case operation
          when "in"           then amount
          when "out", "trans" then -1 * amount
          end
        end

        # set the amounts only for trans, out
        def set_amount
          case operation
            when "out", "trans" then self.amount = -1 * amount
          end
        end

        # Validates the accounts
        def valid_money_accounts
          valid_account_id
          valid_to_id
        end

        # Check the account_id
        def valid_account_id
          err = false

          if account_id.present?
            begin
              ac = Account.org.find(account_id)
              err = true unless ac.accountable_type == "MoneyStore"
            rescue
              err = true
            end

            self.errors[:account_id] << I18n.t("errors.messages.inclusion") if err
          end
        end

        # Check the valid to_id based on the operation
        def valid_to_id
          err = false
          klass = trans? ? "MoneyStore" : "Contact"

          if to_id.present?
            begin
              ac = Account.org.find(to_id)
              err = true unless ac.accountable_type == klass
            rescue
              err = true
            end

            self.errors[:to_id] << I18n.t("errors.messages.inclusion") if err
          end
        end

    end
  end
end
