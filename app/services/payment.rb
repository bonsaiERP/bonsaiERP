# encoding: utf-8
class Payment < BaseService

  # Attributes
  attribute :transaction_id, Integer 
  attribute :account_id, Integer
  attribute :date, Date 
  attribute :amount, Decimal
  attribute :exchange_rate, Decimal
  attribute :reference, String
  attribute :interest, Decimal
  attribute :verification, Boolean

  # Validations
  validates_presence_of :transaction, :transaction_id, :account, :account_id, :reference
  validates_numericality_of :amount, :interest, greater_than_or_equal_to: 0
  validates_numericality_of :exchange_rate, greater_than: 0
  validate :valid_amount_or_interest
  validate :valid_transaction_balance

  # Delegations
  delegate :total, :balance, to: :transaction, prefix: true, allow_nil: true

  def initialize(attrs = {})
    super
    self.verification = false if verification.nil?
  end

  def currency_id
    account.currency_id
  end

  def account
    @account ||= begin
      Account.find(account_id)
    rescue
      nil
    end
  end

  def transaction
    @transaction ||= begin
      Transaction.find(transaction_id)
    rescue
      nil
    end
  end

private
  def valid_amount_or_interest
    if amount.to_f <= 0 && interest.to_f <= 0
      self.errors[:base] = I18n.t('errors.messages.payment.invalid_amount_or_interest')
    end
  end

  def valid_transaction_balance
    if amount.to_f > transaction_balance.to_f
      self.errors[:amount] << 'Ingreso una cantidad mayor que el balance'
    end
  end
end
