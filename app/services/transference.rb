# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transference < BaseService
  attr_reader :ledger

  # Attributes
  attribute :account_id, Integer
  attribute :account_to_id, Integer
  attribute :date, Date
  attribute :amount, Decimal, default: 0
  attribute :exchange_rate, Decimal, default: 1
  attribute :reference, String
  attribute :verification, Boolean, default: false

  # Validations
  validates_presence_of :account_id, :account_to, :account_to_id, :account_to, :reference, :date
  validates_numericality_of :amount, greater_than: 0
  validates_numericality_of :exchange_rate, greater_than: 0
  validate :valid_date
  validate :valid_accounts_currency

  delegate :currency, :inverse?, to: :currency_exchange

  # Initializes and sets verification to false if it's not set correctly
  def initialize(attrs = {})
    super
    self.verification = false unless [true, false].include?(verification)
  end

  def account
    @account = Account.active.find_by_id(account_id)
  end

  def account_to
    @account = AccountQuery.new.bank_cash.find_by_id(account_to_id)
  end

private
  # Builds and AccountLedger instance with some default data
  def build_ledger(attrs = {})
    AccountLedger.new({
      account_id: account_id, exchange_rate: conv_exchange_rate,
      account_to_id: account_to_id, inverse: inverse?,
      reference: reference, date: date, currency: account_to.currency
    }.merge(attrs))
  end

  # Inverse of verification?, no need to negate when working making more
  # readable code
  def conciliate?
    !verification?
  end

  def valid_date
    self.errors.add(:date, I18n.t('errors.messages.payment.date') ) unless date.is_a?(Date)
  end

  def currency_exchange
    @currency_exchange ||= CurrencyExchange.new(
      account: account, account_to: account_to, exchange_rate: exchange_rate
    )
  end

  def total_exchange
    currency_exchange.exchange(amount + interest)
  end

  def amount_exchange
    currency_exchange.exchange(amount)
  end

  # Exchange rate used using inverse
  def conv_exchange_rate
    currency_exchange.exchange_rate
  end

  def current_organisation
    OrganisationSession
  end

  # Indicates conciliation based on the type of account
  def conciliation?
    return true if conciliate?

    [account, account_to].any? {|v| v.is_a?(Bank) } ? conciliate? : true
  end

  def valid_accounts_currency
    unless currency_exchange.valid?
      self.errors.add(:base, I18n.t('errors.messages.payment.valid_accounts_currency', currency: currency))
    end
  end
end

