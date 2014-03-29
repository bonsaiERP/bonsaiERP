# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transference < BaseForm
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

  delegate :currency, :inverse?, :same_currency?, to: :currency_exchange
  delegate :currency, to: :account, prefix: true
  delegate :currency, to: :account_to, allow_nil: true, prefix: true

  # Initializes and sets verification to false if it's not set correctly
  def initialize(attrs = {})
    super

    self.verification = false unless [true, false].include?(verification)
  end

  def account
    @account ||= Account.active.find_by_id(account_id)
  end

  def account_to
    @account_to ||= Accounts::Query.new.money.find_by_id(account_to_id)
  end

  def transfer
    self.exchange_rate = 1  if account_currency == account_to_currency

    return false unless valid?
    @ledger = build_ledger

    commit_or_rollback do
      res = ledger.save_ledger
      set_errors(ledger) unless res

      res
    end
  end

  private

    # Builds and AccountLedger instance with some default data
    def build_ledger
      AccountLedger.new(
        account_id: account_id, exchange_rate: conv_exchange_rate,
        account_to_id: account_to_id, inverse: inverse?, operation: 'trans',
        reference: reference, date: date,
        currency: account_to.currency,
        status: get_status,
        amount: amount_exchange
      )
    end

    def valid_date
      self.errors.add(:date, I18n.t('errors.messages.payment.date') ) unless date.is_a?(Date)
    end

    def currency_exchange
      @currency_exchange ||= CurrencyExchange.new(
        account: account, account_to: account_to, exchange_rate: exchange_rate
      )
    end

    def amount_exchange
      if inverse?
        amount * exchange_rate
      else
        amount / exchange_rate
      end
    end

    # Exchange rate used using inverse
    def conv_exchange_rate
      currency_exchange.exchange_rate
    end

    def current_organisation
      OrganisationSession
    end

    def get_status
      if verification? && any_bank_acccount?
        'pendent'
      else
        'approved'
      end
    end

    def any_bank_acccount?
      account.is_a?(Bank) || account_to.is_a?(Bank)
    end

    def valid_accounts_currency
      unless currency_exchange.valid?
        self.errors.add(:base, I18n.t('errors.messages.payment.valid_accounts_currency', currency: currency))
      end
    end

end

