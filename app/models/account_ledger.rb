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
  OPERATIONS = %w(transin transout contin contout payin payout intin intout devin devout).freeze

  ########################################
  # Callbacks
  before_validation :set_currency

  before_create :set_creator
  before_save   :set_approver, if: :conciliation?

  with_options if: :conciliation? do |upd|
    upd.before_save :update_account_amount
    upd.before_save :update_to_amount
  end

  # Includes
  include ActionView::Helpers::NumberHelper

  ########################################
  # Relationships
  belongs_to :account, :autosave => true
  belongs_to :to, :class_name => "Account", :autosave => true
  belongs_to :transaction
  belongs_to :currency
  belongs_to :contact
  belongs_to :project

  belongs_to :approver, :class_name => "User"
  belongs_to :nuller,   :class_name => "User"
  belongs_to :creator,  :class_name => "User"

  ########################################
  # Validations
  validates_presence_of :amount, :account_id, :account, :reference, :currency, :currency_id

  validates_inclusion_of :operation, :in => OPERATIONS
  validates_numericality_of :exchange_rate, :greater_than => 0

  validates :reference, :length => { :within => 3..150, :allow_blank => false }

  ########################################
  # scopes
  scope :pendent, where(:conciliation => false, :active => true)
  scope :con,     where(:conciliation => true)
  scope :nulled,  where(:active => false)
  scope :active,  where(:active => true)
  scope :staff,   lambda{|st_id|
    s = AccountLedger.scoped
    where(s.table[:contact_id].eq(st_id).or(s.table[:staff_id].eq(st_id) ) )
    .order("created_at DESC")
  }

  ########################################
  # delegates
  delegate :name, :symbol, :code, :to => :currency, :prefix => true, :allow_nil => true

  delegate :currency_id, :name, :original_type, :accountable_type, :accountable, :amount, :accountable_id,
    :to => :account, :prefix => true, :allow_nil => true

  delegate :currency_id, :name, :original_type, :accountable_type, :accountable, :amount, :accountable_id,
    :to => :to, :prefix => true, :allow_nil => true

  delegate :type, :currency_id, :to => :transaction, :prefix => true, :allow_nil => true

  OPERATIONS.each do |op|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{op}?; "#{op}" == operation; end
    CODE
  end
 
  def conciliate_account
    if !active?
      self.errors[:base] << I18n.t('errors.messages.account_ledger.null_conciliation')
      
      false
    else
      self.conciliation = true

      self.save!
    end
  end

  def to_s
    "%06d" % id
  end

  # Determines if the ledger can be nulled
  def can_destroy?
    active? and not(conciliation?)
  end

  def nulled?
    not(active)
  end

  def amount_currency
    begin
      amount * exchange_rate_currency
    rescue
      0
    end
  end

  def exchange_rate_currency
    inverse? ? 1/exchange_rate : exchange_rate
  end

  def related_account
    if transaction_id.present?
      transaction
    elsif ac_id == account_id
      to
    else
      account
    end
  end

  def selected_account
    if ac_id == account_id
      account
    else
      to
    end
  end

  def other_account
    if ac_id == account_id
      to
    else
      account
    end
  end

  # returns the ac_id depending on the type od the account
  def payment_link_id
    if account_accountable_type === "MoneyStore"
      account_id
    else
      to_id
    end
  end

  def ac_id=(val)
    val = account_id if val === 0 or val.blank?
    @ac_id = val
  end

private
  def set_currency
    self.currency_id = account_currency_id
  end

  def set_creator
    self.creator_id = UserSession.user_id
  end

  def set_approver
    self.approver_id = UserSession.user_id
  end

  def update_account_amount
    account.amount += amount
    self.account_balance = account.amount

    account.save!
  end

  # Updates the amount of the account to
  def update_to_amount
    return unless to_id.present?

    to.amount -= amount
    self.to_balance = to.amount

    account.save!
  end
end
