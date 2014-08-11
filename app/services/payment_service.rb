# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentService < BaseService
  attr_reader :ledger, :movement

  # Attributes
  attribute :account_id, Integer
  attribute :account_to_id, Integer
  attribute :date, Date
  attribute :amount, Decimal, default: 0
  attribute :exchange_rate, Decimal, default: 1
  attribute :reference, String
  attribute :verification, Boolean, default: false

  # Validations
  validates_presence_of :account_id, :account_to, :account_to_id, :reference, :date
  validates_numericality_of :amount, greater_than: 0
  validates_numericality_of :exchange_rate, greater_than: 0
  validate :valid_date
  validate :valid_accounts_currency

  delegate :currency, :inverse?, :same_currency?, to: :currency_exchange
  delegate :amount, :currency, to: :account_to, prefix: true, allow_nil: true
  delegate :total, :balance, :currency, to: :movement, prefix: true, allow_nil: true

  # Initializes and sets verification to false if it's not set correctly
  def initialize(attrs = {})
    super
    self.verification = false unless [true, false].include?(verification)
  end

  def account_to
    @account_to ||= Account.active.find_by_id(account_to_id)
  end

  def amount
    @amount.is_a?(BigDecimal) ? @amount : "0".to_d
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

  def get_status
    if verification? && account_to.is_a?(Bank)
      'pendent'
    else
      'approved'
    end
  end

  def valid_date
    self.errors.add(:date, I18n.t('errors.messages.payment.date') ) unless date.is_a?(Date)
  end

  def set_approver
    unless movement.is_approved?
      movement.approver_id = UserSession.id
      movement.approver_datetime = Time.zone.now
    end
  end

  def valid_accounts_currency
    unless currency_exchange.valid?
      self.errors.add(:base, I18n.t('errors.messages.payment.valid_accounts_currency', currency: currency))
    end
  end

  def currency_exchange
    @currency_exchange ||= CurrencyExchange.new(
      account: movement, account_to: account_to, exchange_rate: exchange_rate
    )
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

  def complete_accounts?
    movement.present? && account_to.present?
  end

  def valid_amount
    if complete_accounts? && movement_currency === account_to_currency && amount > movement_balance
      self.errors.add :amount, I18n.t('errors.messages.payment.balance')
    end
  end
end
