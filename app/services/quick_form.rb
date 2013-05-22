# encoding: utf-8
# Generates a quick income with all data
class QuickForm < BaseForm

  attr_reader :account_ledger, :transaction

  attribute :ref_number    , String
  attribute :account_to_id , Integer
  attribute :contact_id    , Integer
  attribute :date          , Date
  attribute :amount        , Decimal
  attribute :bill_number   , String
  attribute :reference     , String

  validates_presence_of :account_to, :account_to_id, :contact, :contact_id, :date
  validates_numericality_of :amount, greater_than: 0
  validate :valid_account_to

  delegate :currency, to: :account_to, allow_nil: true

  def initialize(attributes = {})
    super

    self.date = date || Date.today
    self.amount = amount.to_f.abs
  end

private
  def account_to
    @account_to ||= Accoun.find_by_id(account_to_id)
  end

  def transaction_attributes
    {
      ref_number: ref_number, date: date, currency: currency,
      bill_number: bill_number, contact_id: contact_id,
      due_date: date
    }
  end

  def build_ledger(attrs={})
    AccountLedger.new({
      account_to_id: account_to_id,
      exchange_rate: 1, date: date,
    }.merge(attrs)) {|al|
      al.status = 'approved'
      al.currency = currency
      al.creator_id = UserSession.id
      al.reference = get_reference
    }
  end

  # Use method find_by_id to prevent exception
  def account_to
    @account_to ||= Account.find_by_id(account_to_id)
  end

  def contact
    @contact ||= Contact.find_by_id(contact_id)
  end

  def valid_account_to
    unless account_to.is_a?(Cash) || account_to.is_a?(Bank)
      self.errors[:account_to_id] << I18n.t('errors.messages.quick_income.valid_account_to')
    end
  end
end
