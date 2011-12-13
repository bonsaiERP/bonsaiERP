# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com

module Models::AccountLedger
  # Class used to create devolutions for incomes and buys
  class Devolution
    attr_reader :transaction, :account_ledger, :contact_account

    def initialize(params)
      @transaction = ::Transaction.find(params[:transaction_id])

      @account_ledger = ::AccountLedger.new
      account_ledger.transaction_id = transaction.id
      account_ledger.currency_id    = transaction.currency_id
      @contact_account = find_or_create_contact_account
    end

    def save
      res = true

      ::AccountLedger.transaction do
        @account_ledger.save
        @transaction.save
      end
    end

    # Returns all the accounts for a devolution
    def accounts
      @accounts ||= [contact_account] + Account.money.where(:currency_id => @transaction.currency_id).all
    end

    private

    def find_or_create_contact_account
      contact = transaction.contact
      con = contact.account_cur(transaction.currency_id)
      con = Account.create!(:name => contact.to_s, :currency_id => transaction.currency_id ) {|v| v.amount = 0} unless con
      con
    end
  end
end
