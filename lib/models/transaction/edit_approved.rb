# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction
    class EditApproved
      attr_reader :old_transaction, :transaction

      def initialize(transaction)
        @transaction = transaction
        @old_transaction = ::Transaction.find(@transaction.id)
      end

      def update
        if transaction.account_ledgers.pendent.any?
          transaction.errors[:base] << I18n.t("errors.messages.transaction.unconcilied_ledgers")
          return false
        end

        if old_transaction.total_paid > transaction.balance
          refund
        end
      end

      def refund
        account = transaction.contact_account_cur(transaction.currency_id)
        amount  = old_transaction.total_paid - transaction.balance
        klass   = transaction.class.to_s.downcase

        @current_ledger = account.account_ledgers.build(
          :account_id => account.id,
          :amount => amount,
          :exchange_rate => 1,
          :transaction_id => transaction.id,
          :reference => I18n.t("transaction.#{klass}.refund", :transaction => transaction),
          :operation => refund_operation
        ) {|al| 
          al.conciliation = true
          al.currency_id = account.currency_id
        }

        puts @current_ledger.attributes
      end

      def refund_operation
        transaction.is_a?(Income) ? "in" : "out"
      end
    end
end
