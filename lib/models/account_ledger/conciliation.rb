# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Conciliation
  
  extend ActiveSupport::Concern

  included do
    #after_create :conciliate_account, :if => :make_conciliation?
    after_update :check_transaction_conciliation, :if => "transaction_id.present?"
  end

  module InstanceMethods
    # Makes the conciliation to update accounts
    def conciliate_account
      return false unless can_conciliate?

      self.approver_id = UserSession.user_id
      self.approver_datetime = Time.zone.now

      valid_contact_amount

      return false if errors.any?

      self.conciliation = true
      # should run before update_related_accounts
      valid_amount

      update_related_accounts
      self.account_balance = account.amount
      self.to_balance      = to.amount if to_id.present? and transaction_id.blank?

      return false if errors.any?

      self.save
    end

    # Determines if the account ledger can conciliate
    def can_conciliate?
      not(conciliation?) and active?
    end

    # Updates the transaction if needed if all the payments have been done and conciliated
    def check_transaction_conciliation
      if transaction.balance === 0 and transaction.account_ledgers.pendent.empty?
        raise ActiveRecord::Rollback unless transaction.update_attribute(:deliver, true)
      end
    end

    def conciliate_transaction_account
      res = true

      self.class.transaction do
        res = self.save
        if res and transaction.balance == 0 and transaction.type == "Income" and transaction.account_ledgers.pendent.empty?
          transaction.deliver = true
        end
        res = res and transaction.save
        raise ActiveRecord::Rollback unless res
      end

      res
    end


    # Validates the amount for a contact depending the amount
    def valid_contact_amount
      if currency_id and exchange_rate > 0 and account_id.present?
        if in?
          if account.accountable_type === 'Contact' and account.amount.abs < amount
            self.errors[:amount]  << I18n.t("errors.messages.account_ledger.amount")
            self.errors[:base]  << I18n.t("errors.messages.account_ledger.amount")
          end
        elsif out? or trans?
          if account.amount < amount.abs
            self.errors[:amount]  << I18n.t("errors.messages.account_ledger.amount")
            self.errors[:base]  << I18n.t("errors.messages.account_ledger.amount")
          end
        end
      end
    end


    private
    def update_related_accounts
      account.amount += amount
      if to_id.present? and transaction_id.blank?
        to.amount += -(self.amount * self.exchange_rate)
      end
    end

  end

  module ClassMethods
  end


end
