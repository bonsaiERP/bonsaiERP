# encoding: utf-8
# Base class used to make devolutions for Income and Expense models
class Devolution < BaseService
  attr_reader :ledger, :transaction

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

  # Sets all values but will set verification to false if is not
  # correctly set
  def initialize(attrs = {})
    super
    self.verification = false unless [true, false].include?(verification)
  end

  def account_to
    @account = Account.find_by_id(account_to_id)
  end

private
  # Builds an instance of AccountLedger with basic data for  devolution
  def build_ledger(attrs = {})
      AccountLedger.new({
                         account_id: account_id, exchange_rate: exchange_rate,
                         amount: 0, account_to_id: account_to_id,
                         reference: reference, date: date
      }.merge(attrs))
  end

  def conciliate?
    !verification?
  end

  def valid_date
    self.errors.add(:date, I18n.t('errors.messages.payment.date')) unless date.is_a?(Date)
  end

  def set_approver
    unless transaction.is_approved?
      transaction.approver_id = UserSession.id
      transaction.approver_datetime = Time.zone.now
    end
  end
end

