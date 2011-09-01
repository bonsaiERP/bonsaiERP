# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Conciliation
  
  extend ActiveSupport::Concern

  included do
    #after_create :conciliate_account, :if => :make_conciliation?
  end

  module InstanceMethods
    # Makes the conciliation to update accounts
    def conciliate_account
      return false unless can_conciliate?

      self.approver_id = UserSession.user_id
      self.approver_datetime = Time.zone.now

      # Validate amount
      valid_contact_amount
      return false if errors.any?

      self.conciliation = true
      update_related_accounts
      self.account_balance = account.amount
      self.to_balance      = to.amount

      self.save
    end

    # Determines if the account ledger can conciliate
    def can_conciliate?
      not(conciliation?) and active?
    end

    #def conciliate_transaction_account
    #  self.conciliation = true
    #  update_related_accounts

    #  #res = true
    #  #self.class.transaction do
    #  #  res = self.save
    #  #  res = res and transaction.save
    #  #  raise ActiveRecord::Rollback unless res
    #  #end

    #  self.save
    #end
    def valid_contact_amount
      if ::Contact::TYPES.include?(account_original_type)
        if currency_id and exchange_rate > 0
          self.errors[:amount]  << I18n.t("account_ledger.errors.invalid_amount") if -account.amount < amount_currency
        end
      end
    end


    private
    def update_related_accounts
      puts "AMT: #{amount}"
      account.amount += amount
      to.amount += -(amount * exchange_rate)
    end

  end

  module ClassMethods
  end


end
