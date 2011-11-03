# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction
  # Stores changes and check validatioins according to the state
  class Edit
    attr_reader :old_transaction, :transaction, :history

    def initialize(transaction)
      @transaction = transaction
      @old_transaction = ::Transaction.find(@transaction.id) if @transaction.persisted?
    end

    def update
      #create replica
      return unless transaction.persisted?

      create_history

      unless transaction.draft? 
        if transaction.account_ledgers.pendent.any?
          transaction.errors[:base] << I18n.t("errors.messages.transaction.unconcilied_ledgers")
          return false
        end

        if old_transaction.total_paid > transaction.balance
          refund
        end
      end
    end

    def refund
      @account = transaction.contact_account_cur(transaction.currency_id)
      amount  = old_transaction.total_paid - transaction.balance
      klass   = transaction.class.to_s.downcase

      @account.amount = -amount

      @current_ledger = @account.account_ledgers.build(
        :account_id => @account.id,
        :amount => amount,
        :exchange_rate => 1,
        :transaction_id => transaction.id,
        :reference => I18n.t("transaction.#{klass}.refund", :transaction => transaction),
        :operation => refund_operation
      ) {|al| 
        al.conciliation = true
        al.currency_id = @account.currency_id
      }

      #@current_ledger.save
      #account.save
    end

    def save
      res = true
      transaction.class.transaction do
        res = @current_ledger.save if @current_ledger
        res = @account.save && res if @account
        res = transaction.save
        raise ActiveRecord::Rollback unless res
      end

      res
    end

    def refund_operation
      transaction.is_a?(Income) ? "in" : "out"
    end

    def create_history
      @history = transaction.transaction_histories.build
      @history.data = old_transaction.attributes.symbolize_keys
      @history.data[:taxis_ids] = old_transaction.taxis_ids
      @history.user_id = old_transaction.modified_by
      @history.data[:transaction_details] = old_transaction.transaction_details.map {|v| v.attributes.symbolize_keys }
    end

  end
end
