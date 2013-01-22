# encoding: utf-8
# Generates a quick income with all data
class QuickTransaction < BaseService

  attr_reader :account_ledger

  attribute :ref_number    , String
  attribute :account_to_id , Integer
  attribute :contact_id    , Integer
  attribute :date          , Date
  attribute :amount        , Decimal
  attribute :bill_number   , String
  attribute :verification  , Boolean, default: false

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
    {ref_number: ref_number, date: date, currency: currency,
     bill_number: bill_number, contact_id: contact_id,
     state: 'paid', payment_date: date
    }
  end

  # Builds a ledger with conciliation == true
  def build_ledger(attrs={})
    AccountLedger.new({
      account_to_id: account_to_id,
      exchange_rate: 1, date: date,
    }.merge(attrs)) {|al| 
      al.conciliation = conciliate?
      al.currency = currency
      al.creator_id = UserSession.id
      al.approver_id = UserSession.id
    }
  end

  def conciliate?
    if account_to.is_a?(Cash)
      true
    else
      !verification
    end
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
