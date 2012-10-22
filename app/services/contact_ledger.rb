# encoding: utf-8
class ContactLedger
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :account_id, Integer
  attribute :currency_id, Integer
  attribute :amount, Decimal
  attribute :reference, String
  attribute :amount, Decimal
  attribute :operation, String
  attribute :exchange_rate, Decimal

  ########################################
  # Validations
  validates_presence_of :contact_id

  attr_reader :account_ledger

  def create_in
    @account_ledger = AccountLedger.new(attributes)
  end

  def create_out

  end

  private
    def contact
      @contact ||= Contact.find_by_id(contact_id)
    end
end
