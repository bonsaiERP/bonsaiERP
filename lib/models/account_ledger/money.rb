# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Money

  extend ActiveSupport::Concern

  included do
    attr_accessor :contact_id

    #before_save :before_save_money , :if => :money?
    with_options :if => :new_money? do |trans|
      # callbacks
      trans.before_validation :set_exchange_rate
      trans.before_validation :set_or_create_contact_account, :unless => :trans?
      trans.before_save :set_ledger_amount
      trans.before_save :valid_money_accounts
    end

    with_options :if => :money? do |trans|
      trans.validates_presence_of :account_id#, :contact_id, :if => :money?
      trans.validates_presence_of :contact_id, :unless => :trans?
      #trans.before_create :set_or_create_contact_account
    end
  end

  ############################
  module ClassMethods

    # Creates a new ledger, but if the account is nor a MoneyStore returns false
    def new_money(params = {})
      params.transform_date_parameters!("date")
      params.symbolize_keys.assert_valid_keys( :operation, :account_id, :to_id, :amount, :reference, :date, :exchange_rate, :description, :contact_id )

      ac = AccountLedger.new(params)
      def ac.money?; true; end
      ac.conciliation = false

      return false unless ac.account_accountable.is_a?(MoneyStore)
      
      ac
    end
  end

  ############################
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
    def set_ledger_amount
      case operation
        when "out", "trans" then self.amount = -1 * amount
      end
    end

    # Validates the accounts
    def valid_money_accounts
      if account_id == to_id
        self.errors[:base] << I18n.t("errors.messages.account_ledger.same_account")
        return false
      end

      valid_account_id
      valid_to_id
    end

    # Creates the contact account
    def set_or_create_contact_account
      begin
        c = Contact.org.find(contact_id)
      rescue
        self.errors[:contact_id] << I18n.t("errors.messages.account_ledger.invalid_contact")
        return false
      end

      ac = c.account_cur(currency_id)

      unless ac
        type_id = AccountType.org.find_by_account_number(c.class.to_s).id
      
        ac = c.accounts.build(:name => c.to_s, :currency_id => currency_id) {|aco|
          aco.amount = 0
          aco.original_type = c.class.to_s
          account_type_id = type_id
        }

        return false unless ac.save
      end

      self.to_id = ac.id
    end

    # Check the account_id
    def valid_account_id
      if account_id.present?
        begin
          ac = Account.org.find(account_id)
          unless ac.accountable_type == "MoneyStore"
            self.errors[:base] << I18n.t("errors.messages.inclusion")
            return false
          end
        rescue
          self.errors[:account_id] << I18n.t("errors.messages.inclusion")
          return false
        end
      end
    end

    # Check the valid to_id based on the operation
    def valid_to_id
      klass = trans? ? "MoneyStore" : "Contact"

      if to_id.present?
        begin
          ac = Account.org.find(to_id)
          unless ac.accountable_type == klass
            self.errors[:to_id] << I18n.t("errors.messages.inclusion")
            return false
          end
        rescue
          self.errors[:to_id] << I18n.t("errors.messages.inclusion")
          return false
        end
      end
    end


  end

end
