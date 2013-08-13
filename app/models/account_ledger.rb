# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  include ::Models::Updater

  ########################################
  # Constants
  # contin  = Advance in that will add the amount to the Contact account
  # contout = Advance out that will add the amount to the Contact account
  # payin  = Payment in Income
  # payout = Paymen out Expense
  # intin  = Interests in
  # intout = Interestsout
  # devin  = Devolution in Income
  # devout = Devolution out Expense
  OPERATIONS = %w(trans contin contout payin payout
                  intin intout devin devout).freeze
  STATUSES = %w(pendent approved nulled).freeze

  ########################################
  # Callbacks
  before_validation :set_currency
  before_create :set_creator

  # Includes
  include ActionView::Helpers::NumberHelper

  ########################################
  # Relationships
  belongs_to :account
  belongs_to :account_to, class_name: 'Account'

  belongs_to :project

  belongs_to :approver, class_name: 'User'
  belongs_to :nuller,   class_name: 'User'
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  ########################################
  # Validations
  validates_presence_of :amount, :account_id, :account, :account_to_id,
                        :account_to, :reference, :currency, :date
  validate :different_accounts

  validates_inclusion_of :operation, in: OPERATIONS
  validates_inclusion_of :status, in: STATUSES
  validates_numericality_of :exchange_rate, greater_than: 0

  validates :reference,
            length: { within: 3..250, allow_blank: false }

  ########################################
  # scopes
  scope :pendent, -> { where(status: 'pendent') }
  scope :nulled,  -> { where(status: 'nulled') }
  scope :approved, -> { where(status: 'approved') }

  ########################################
  # delegates
  delegate :name, :amount, :currency, :contact,
           to: :account, prefix: true, allow_nil: true
  delegate :name, :amount, :currency, :contact,
           to: :account_to, prefix: true, allow_nil: true
  delegate :same_currency?, to: :currency_exchange

  OPERATIONS.each do |op|
    define_method :"is_#{op}?" do
      op == operation
    end
  end

  STATUSES.each do |st|
    define_method :"is_#{st}?" do
      st == status
    end
  end

  def to_s
    sprintf '%06d', id
  end

  # Determines if the ledger can be conciliated or nulled
  def can_conciliate_or_null?
    !(nuller_id.present? || approver_id.present?)
  end

  def amount_currency
    currency_exchange.exchange(amount)
  end

  def save_ledger
    if is_approved?
      ConciliateAccount.new(self).conciliate!
    else
      save
    end
  end

  def update_reference(txt)
    self.old_reference = reference
    self.reference = txt

    save
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
      if account_id == account_to_id
        errors[:account_to_id] << I18n.t('errors.messages.account_ledger.same_account')
      end
    end
end
