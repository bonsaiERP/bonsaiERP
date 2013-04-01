# encoding: utf-8
class TransactionService < BaseService
  attribute :id, Integer
  attribute :ref_number, String
  attribute :date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :total, Decimal
  attribute :exchange_rate, Decimal
  attribute :project_id, Integer
  attribute :bill_number, String
  attribute :due_date, Date
  attribute :description, String
  attribute :direct_payment, Boolean
  attribute :account_to_id, Integer

  attr_reader :transaction, :ledger

  def initialize(attrs = {})
    yield self
    super
  end
end
