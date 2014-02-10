# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loans::PaymentForm < BaseForm
  attribute :account_id, Integer
  attribute :account_to_id, Integer
  attribute :exchange_rate, Decimal, default: 1
  attribute :amount, Decimal, default: 0
  attribute :date, Date
  attribute :reference, String
  attribute :verification, Boolean, default: false

  validates_presence_of :account_to_id, :account_to, :account_id, :reference, :date, :loan
  validates :amount, numericality: { greater_than: 0 }
  validate :valid_loan_amount

  delegate :currency, to: :loan, allow_nil: true, prefix: true
  delegate :currency, to: :account_to, allow_nil: true, prefix: true
  delegate :exchange_rate, to: :currency_exchange, prefix: 'cur'

  alias_method :currency, :loan_currency

  def account_to
    @account_to ||= Account.find_by(id: account_to_id)
  end

  def loan; end

  private

    def get_status
      verification == true ? 'pendent' : 'approved'
    end

    def valid_loan_amount
      if amount && loan.present? && amount_exchange > loan.amount
        errors.add(:amount, I18n.t('errors.messages.less_than_or_equal_to', count: loan.amount))
      end
    end

    def amount_exchange
      currency_exchange.exchange(amount)
    end

    def currency_exchange
      @currency_exchange ||= CurrencyExchange.new(
        account: loan, account_to: account_to, exchange_rate: exchange_rate
      )
    end
end
