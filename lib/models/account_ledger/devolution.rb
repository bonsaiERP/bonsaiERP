# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com

module Models::AccountLedger
  # Class used to create devolutions for incomes and buys
  class Devolution
    attr_reader :transaction, :account_ledger, :contact_account

    def initialize(params)
      @transaction = ::Transaction.find(params[:transaction_id])

      @account_ledger = ::AccountLedger.new(params)
      account_ledger.transaction_id = transaction.id
      account_ledger.currency_id    = transaction.currency_id
      account_ledger.exchange_rate  = 1
      @account_ledger.devolution    = true
      @contact_account = find_or_create_contact_account
    end

    def save
      res = true

      ::AccountLedger.transaction do
        set_ledger_data
        res = account_ledger.save

        set_transaction_data
        res = res && transaction.save
        raise ActiveRecord::Rollback unless res
      end

      res
    end

    # Returns all the accounts for a devolution
    def accounts
      @accounts ||= [contact_account] + Account.money.where(:currency_id => @transaction.currency_id).all
    end

    private
    # Sets all the parameters of the transaction
    def set_transaction_data
      transaction.balance += account_ledger.amount.abs
      transaction.state = 'approved' if transaction.paid?
    end

    # Sets the details for ledger
    def set_ledger_data
      if transaction.is_a?(Income)
        account_ledger.operation = 'out'
        #account_ledger.amount = -account_ledger.amount
      else
        account_ledger.operation = 'in'
      end
    end

    def find_or_create_contact_account
      contact = transaction.contact
      con = contact.account_cur(transaction.currency_id)
      con = Account.create!(:name => contact.to_s, :currency_id => transaction.currency_id ) {|v| v.amount = 0} unless con
      con
    end
  end
end
