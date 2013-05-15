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
  #attribute :bill_number, String
  attribute :due_date, Date
  attribute :description, String
  attribute :direct_payment, Boolean
  attribute :account_to_id, Integer
  attribute :reference, String

  ATTRIBUTES = [:date, :contact_id, :total, :exchange_rate, :project_id, :due_date, :description, :direct_payment, :account_to_id, :reference].freeze
  TRANS_ATTRIBUTES = [:date, :contact_id, :total, :exchange_rate, :project_id, :due_date, :description]

  attr_reader :transaction, :ledger

  validates_presence_of :transaction
  validates_numericality_of :total
  validate :unique_item_ids

  delegate :items, to: :transaction

  def self.income_expense_attributes
    [:date, :due_date, :contact_id, :currency, :exchange_rate, :project_id, :description]
  end

  # Finds the income and sets data with the income found
  def set_service_attributes(trans)
    self.ref_number = trans.ref_number
    self.total      = trans.total
    self.due_date   = trans.due_date
    @transaction    = trans
  end

private
  def unique_item_ids
    UniqueItem.new(self).valid?
  end

  def item_ids
    @item_ids ||= items.map(&:item_id)
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end

  def direct_payment?
    direct_payment === true
  end

  def set_details_original_prices
    items.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end
end
