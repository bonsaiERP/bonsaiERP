# encoding: utf-8
class Payment < BaseService

  attr_reader :transaction

  attribute :transaction_id, Integer 
  attribute :account_id, Integer
  attribute :date, Date 
  attribute :amount, Decimal
  attribute :exchange_rate, Decimal
  attribute :reference, String
  attribute :interest, Decimal

  def initialize(trans)
    raise 'You must set with a Transaction class' unless trans.is_a?(Transaction)
    @transaction = trans
  end

  def currency_id
    account.currency_id
  end

  def account
    @account ||= Account.find(account_id)
  end
end
