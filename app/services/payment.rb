# encoding: utf-8
class Payment < BaseService
  attr_reader :ledger, :int_ledger, :transaction

  # Attributes
  attribute :account_id, Integer
  attribute :account_to_id, Integer
  attribute :date, Date
  attribute :amount, Decimal, default: 0
  attribute :exchange_rate, Decimal, default: 1
  attribute :reference, String
  attribute :interest, Decimal, default: 0
  attribute :verification, Boolean, default: false

  # Validations
  validates_presence_of :account_id, :account_to, :account_to_id, :reference, :date
  validates_numericality_of :amount, :interest, greater_than_or_equal_to: 0
  validates_numericality_of :exchange_rate, greater_than: 0
  validate :valid_amount_or_interest
  validate :valid_date
  validate :valid_accounts_currency

  delegate :currency, to: :current_organisation

  # Initializes and sets verification to false if it's not set correctly
  def initialize(attrs = {})
    super
    self.verification = false unless [true, false].include?(verification)
  end

  def account_to
    @account = Account.active.find_by_id(account_to_id)
  end

private
  # Builds and AccountLedger instance with some default data
  def build_ledger(attrs = {})
    AccountLedger.new({
      account_id: account_id, operation: '', exchange_rate: exchange_rate,
      amount: 0, account_to_id: account_to_id,
      reference: reference, date: date
    }.merge(attrs))
  end

  def valid_amount_or_interest
    if amount.to_f <= 0 && interest.to_f <= 0
      self.errors.add :base, I18n.t('errors.messages.payment.invalid_amount_or_interest')
    end
  end

  # Inverse of verification?, no need to negate when working making more
  # readable code
  def conciliate?
    !verification?
  end

  def valid_date
    self.errors.add(:date, I18n.t('errors.messages.payment.date') ) unless date.is_a?(Date)
  end

  def set_approver
    unless transaction.is_approved?
      transaction.approver_id = UserSession.id
      transaction.approver_datetime = Time.zone.now
    end
  end

  def valid_accounts_currency
    unless currency_exchange.valid?
      self.errors.add(:base, I18n.t('errors.messages.payment.valid_accounts_currency', currency: currency))
    end
  end

  def currency_exchange
    @currency_exchange ||= CurrencyExchange.new(
      account: transaction, account_to: account_to, exchange_rate: exchange_rate
    )
  end

  def current_organisation
    OrganisationSession
  end
end
