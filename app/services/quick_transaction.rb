# encoding: utf-8
# Generates a quick income with all data
class QuickTransaction < BaseService
  include Virtus

  attr_reader :transaction, :account_ledger, :contact

  attribute :ref_number  , String
  attribute :account_id  , Integer
  attribute :contact_id  , Integer
  attribute :date        , Date
  attribute :amount      , Decimal
  attribute :bill_number , String
  attribute :fact        , Boolean

  def initialize(attributes = {})
    super attributes

    self.ref_number = ref_number || get_ref_number
    self.fact = [true, false].include?(fact) ? fact : true
    self.date = date || Date.today
    self.amount = amount.to_f.abs
  end

  def create
    res = true
    ActiveRecord::Base.transaction do
      res = create_transaction

      res = create_ledger && res

      unless res
        set_errors(:income, :account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

private
  def get_ref_number; end

  def create_transaction; end

  def ledger_amount; end

  def ledger_operation; end

  def set_transaction_users
    transaction.creator_id = UserSession.user_id
    transaction.approver_id = UserSession.user_id
  end

  def transaction_attributes
    {ref_number: ref_number, date: date, currency_id: currency_id,
     bill_number: bill_number, fact: fact, contact_id: contact_id,
     state: 'paid'
    }
  end

  def create_ledger
    @account_ledger = initialize_ledger

    @account_ledger.save
  end

  def initialize_ledger
    AccountLedger.new(
      amount: ledger_amount, account_id: account_id,
      reference: ledger_reference, operation: ledger_operation,
      exchange_rate: 1, contact_id: contact_id, date: date
    ) do |al|
      al.transaction_id = transaction.id
      al.conciliation = true
    end
  end

  def ledger_reference
  end

  def account
    @account ||= Account.find_by_id(account_id)
  end

  def currency_id
    if account.present?
      account.currency_id
    else
      nil
    end
  end
end
