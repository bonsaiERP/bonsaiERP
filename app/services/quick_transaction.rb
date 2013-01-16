# encoding: utf-8
# Generates a quick income with all data
class QuickTransaction < BaseService
  include Virtus

  attr_reader :account_ledger, :contact

  attribute :ref_number    , String
  attribute :account_to_id , Integer
  attribute :contact_id    , Integer
  attribute :date          , Date
  attribute :amount        , Decimal
  attribute :bill_number   , String

  def initialize(attributes = {})
    super

    self.date = date || Date.today
    self.amount = amount.to_f.abs
  end

private
  def transaction_attributes
    {ref_number: ref_number, date: date, currency: currency,
     bill_number: bill_number, contact_id: contact_id,
     state: 'paid', payment_date: date
    }
  end

  # Builds a ledger with conciliation == true
  def build_ledger(attrs={})
    AccountLedger.new({
      amount: ledger_amount, account_to_id: account_to_id,
      exchange_rate: 1, date: date,
    }.merge(attrs)) {|al| 
      al.conciliation = true
      al.currency = account_to.currency
    }
  end

  def account_to
    @account_to ||= Account.find_by_id(account_to_id)
  end

  def currency
    if account_to.present?
      account_to.currency
    else
      nil
    end
  end
end
