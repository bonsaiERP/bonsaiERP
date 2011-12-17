# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::AccountLedger::Conciliation
  
  extend ActiveSupport::Concern

  included do
    #after_create :conciliate_account, :if => :make_conciliation?
    #after_update :check_transaction_conciliation, :if => "transaction_id.present?"
  end

  class Conciliation
    attr_reader :account_ledger

    def initialize(account_ledger)
      @account_ledger = account_ledger
    end

    def conciliate
      return false unless account_ledger.valid_amount?
      return false unless can_conciliate?

      account_ledger.approver_id = UserSession.user_id
      account_ledger.approver_datetime = Time.zone.now

      update_related_accounts
      account_ledger.conciliation = true

      account_ledger.save
    end

    protected

    # Determines if the account ledger can conciliate
    def can_conciliate?
      not(@account_ledger.conciliation?) and @account_ledger.active?
    end

    def update_related_accounts
      account_ledger.account.amount += account_ledger.amount
      account_ledger.to.amount      += -(account_ledger.amount * account_ledger.exchange_rate)

      account_ledger.account_balance = account_ledger.account.amount
      account_ledger.to_balance      = account_ledger.to.amount
    end

  end
  # End of Conciliation

  # Class for conciliating transactions
  class ConciliateTransaction < Conciliation
    attr_reader :transaction, :type

    def initialize(account_ledger)
      super(account_ledger)
      @transaction = @account_ledger.transaction
      @type = @transaction.type
    end

    def conciliate
      return false unless valid_amount?
      return false unless can_conciliate?

      account_ledger.approver_id = UserSession.user_id
      account_ledger.approver_datetime = Time.zone.now

      update_related_accounts
      account_ledger.conciliation = true
      
      set_transaction_deliver unless @transaction.deliver?
      res = true

      account_ledger.class.transaction do
        res = account_ledger.save
        res = transaction.save && res if transaction.changed?
        raise ActiveRecord::Rollback unless res
      end

      res
    end

    protected

    def set_transaction_deliver
      tot = transaction.account_ledgers.pendent.count
      return if tot > 1

      al = transaction.account_ledgers.pendent.first
      if al.id === account_ledger.id and transaction.balance === 0
        transaction.deliver = true
      end
    end

    def update_related_accounts
      @account_ledger.account.amount += @account_ledger.amount
      @account_ledger.account_balance = @account_ledger.account.amount
    end

    # Check valid amount depending the transaction
    def valid_amount?

      case @account_ledger.account_accountable_type
        when "MoneyStore"
          if @account_ledger.out?
            return false unless @account_ledger.valid_amount?
          end

          true
        when "Contact"
          return false unless valid_contact_amount?

          true
        else
          @account_ledger.errors[:account_id] << I18n.t("errors.messages.inclusion")
          false
      end
    end

    def update_related_accounts
      @account_ledger.account.amount += @account_ledger.amount
    end

    # Validates the amount for a contact depending the amount
    def valid_contact_amount?
      valid = true
      if @account_ledger.in? and -@account_ledger.account.amount < @account_ledger.amount
        valid = false
      elsif @account_ledger.out? and @account_ledger.account.amount < -@account_ledger.amount
        valid = false
      end

      unless valid
        @account_ledger.errors[:amount]  << I18n.t("errors.messages.account_ledger.amount")
        @account_ledger.errors[:base]  << I18n.t("errors.messages.account_ledger.amount")
      end

      valid
    end
  end
  ## End of ConciliateTransaction

  # Makes the conciliation to update accounts
  def conciliate_account
    if transaction_id.present?
      @ledger = ConciliateTransaction.new(self)
    else
      @ledger = Conciliation.new(self)
    end

    @ledger.conciliate

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
