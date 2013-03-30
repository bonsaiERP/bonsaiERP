# encoding: utf-8
class TransactionService < BaseService
  attribute :id, Integer
  attribute :ref_number, String
  attribute :date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :exchange_rate, Decimal
  attribute :project_id, Integer
  attribute :bill_number, String
  attribute :due_date, Date
  attribute :description, String
  attribute :direct_payment, Boolean
  attribute :account_to_id, Integer

  attr_reader :transaction

private
  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end

  def approve_transaction
    transaction.state = 'approved'
    transaction.due_date = transaction.date
    transaction.approver_id = UserSession.id
    transaction.approver_datetime = Time.zone.now
  end
end
