# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com

module Models::AccountLedger
  # Class used to create devolutions for incomes and buys
  class Devolution
    attr_reader :transaction, :account_ledger

    def initialize(params)
      @transaction = ::Transaction.find(params[:transaction_id])

      @account_ledger = ::AccountLedger.new
      account_ledger.transaction_id = transaction.id
      account_ledger.currency_id    = transaction.currency_id

    end

    def save
      res = true

      ::AccountLedger.transaction do
        @account_ledger.save
        @transaction.save
      end
    end

    private

  end
end
