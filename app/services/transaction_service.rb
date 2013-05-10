# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
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
  attribute :reference, String

  validates_numericality_of :total

  attr_reader :transaction, :ledger

  delegate :details, to: :transaction

  def initialize(attrs = {})
    yield self
    super
  end
end
