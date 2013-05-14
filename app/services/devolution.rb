# encoding: utf-8
# Base class used to make devolutions for Income and Expense models
class Devolution < BaseService
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
  validates_presence_of :account_id, :account_to, :account_to_id, :reference, :date
  validates_numericality_of :amount, greater_than: 0
  validates_numericality_of :exchange_rate, greater_than: 0
  validate :valid_date
  validate :valid_transaction_total

  # Delegations
  delegate :total, :balance, to: :transaction, prefix: true, allow_nil: true

  # Sets all values but will set verification to false if is not
  # correctly set
  def initialize(attrs = {})
    super
    self.verification = false unless [true, false].include?(verification)
  end

  def account_to
    @account = Account.find_by_id(account_to_id)
  end

  def transaction; end
private
  # Builds an instance of AccountLedger with basic data for  devolution
  def build_ledger(attrs = {})
      AccountLedger.new({
                         account_id: account_id, exchange_rate: exchange_rate,
                         amount: 0, account_to_id: account_to_id,
                         reference: reference, date: date
      }.merge(attrs))
  end

  def update_transaction
    transaction.balance += amount
    transaction.set_state_by_balance! # Sets state and the user
  end

  def create_ledger
    @ledger = build_ledger(
      amount: ledger_amount, operation: 'devin', account_id: income.id,
      status: get_status
    )
    @ledger.save_ledger
  end

  def valid_date
    self.errors.add(:date, I18n.t('errors.messages.payment.date')) unless date.is_a?(Date)
  end

  # Indicates conciliation based on the type of account
  def get_status
    if verification? && account_to.is_a?(Bank)
      'pendent'
    else
      'approved'
    end
  end

  def set_approver
    unless transaction.is_approved?
      transaction.approver_id = UserSession.id
      transaction.approver_datetime = Time.zone.now
    end
  end

  def valid_transaction_total
    if ( amount.to_f + transaction_balance.to_f ) > transaction_total.to_f
      self.errors.add :amount, I18n.t('errors.messages.devolution.transaction_total')
    end
  end
end
