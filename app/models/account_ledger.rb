# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  ########################################
  # Constants
  # contin  = Advance in that will add the amount to the Contact account
  # contout = Advance out that will add the amount to the Contact account
  # payin  = Payment in
  # payout = Paymen out
  # intin  = Interests in
  # intout = Interestsout
  # devin  = Devolution in
  # devout = Devolution out
  OPERATIONS = %w(trans contin contout payin payout intin intout devin devout).freeze
  STATUSES = %w(pendent approved nulled).freeze

  ########################################
  # Callbacks
  # TODO: review callback
  before_validation :set_currency

  before_create :set_creator
  before_save   :set_approver, if: :conciliation?

  # Includes
  include ActionView::Helpers::NumberHelper

  ########################################
  # Relationships
  belongs_to :account
  belongs_to :account_to, class_name: "Account"

  belongs_to :project

  belongs_to :approver, class_name: "User"
  belongs_to :nuller,   class_name: "User"
  belongs_to :creator,  class_name: "User"

  ########################################
  # Validations
  validates_presence_of :amount, :account_id, :account, :account_to_id, :account_to, :reference, :currency, :date
  validate :different_accounts

  validates_inclusion_of :operation, in: OPERATIONS
  validates_inclusion_of :status, in: STATUSES
  validates_numericality_of :exchange_rate, greater_than: 0

  validates :reference, length: { within: 3..150, allow_blank: false }

  ########################################
  # scopes
  scope :pendent, -> { where(conciliation: false, active: true) }
  scope :con,     -> { where(conciliation: true) }
  scope :nulled,  -> { where(active: false) }
  scope :active,  -> { where(active: true) }

  ########################################
  # delegates
  delegate :name, :amount, :currency, :contact, to: :account, prefix: true, allow_nil: true
  delegate :name, :amount, :currency, :contact, to: :account_to, prefix: true, allow_nil: true
  delegate :same_currency?, to: :currency_exchange

  OPERATIONS.each do |op|
    define_method :"is_#{op}?" do
      op === operation
    end
  end

  STATUSES.each do |st|
    define_method :"is_#{st}?" do
      st === status
    end
  end

  def to_s
    "%06d" % id
  end

  # Determines if the ledger can be conciliated or nulled
  def can_conciliate_or_null?
    active? && not(conciliation?)
  end

  def amount_currency
    currency_exchange.exchange(amount)
  end

  def save_ledger
    if is_approved?
      ConciliateAccount.new(self).conciliate!
    else
      self.save
    end
  end

private
  def currency_exchange
    @currency_exchange ||= CurrencyExchange.new(
      account: account, account_to: account_to, exchange_rate: exchange_rate
    )
  end

  def set_currency
    self.currency = account_to_currency
  end

  def set_creator
    self.creator_id = UserSession.id
  end

  def set_approver
    self.approver_id = UserSession.id
  end

  def different_accounts
    self.errors[:account_to_id] << I18n.t('errors.messages.account_ledger.same_account') if account_id == account_to_id
  end
end
