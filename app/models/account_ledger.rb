# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  ########################################
  # Constants
  # cin  = Advance in that will add the amount to the Contact account
  # cout = Advance out that will add the amount to the Contact account
  # pin  = Payment in
  # pout = Paymen out
  # iin  = Interests in
  # iout = Interestsout
  # din  = Devolution in
  # dout = Devolution out
  OPERATIONS = %w(trans cin cout pin pout iin iout din dout).freeze
  BEHAVIORS = [:devolution, :payment, :transference, :inout].freeze

  ########################################
  # Callbacks
  before_validation :set_currency

  before_create :set_creator
  before_save   :set_approver, if: :conciliation?

  with_options if: :conciliation? do |upd|
    upd.before_save :update_account_amount
    upd.before_save :update_to_amount
  end

  ########################################
  # Attributes
  attr_reader *BEHAVIORS
  attr_reader :ac_id
  # Base amount is the #  amount = base_amount + interests_penalties
  attr_accessor :make_conciliation, :base_amount
  # accessible
  attr_accessible :account_id, :to_id, :date, :operation, :reference, :interests_penalties, :project_id,
    :amount, :exchange_rate, :description, :account_ledger_details_attributes, :contact_id, :base_amount


  # includes
  include ActionView::Helpers::NumberHelper

  # includes related to the model
  #include Models::AccountLedger::Money
  #include Models::AccountLedger::Payment
  #include Models::AccountLedger::Conciliation

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

  ########################################
  # Methods
  BEHAVIORS.each do |met|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{met}?; !!#{met}; end
    CODE
  end

  OPERATIONS.each do |op|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def is_#{op}?; "#{op}" == operation; end
    CODE
  end

  def conciliate_account
    self.conciliation = true

    self.save!
  end
 
  def self.pendent?
    pendent.count > 0
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

  def self.contact(contact_id)
    AccountLedger.where(:contact_id => contact_id).includes(:currency)
    .order("created_at DESC")
  end

  # nulls an account_ledger
  def null_transaction
    return false if conciliation?

    self.nuller_datetime = Time.now

    self.nuller_id = UserSession.user_id
    self.active    = false
  
    if transaction_id.present?
      null_transaction_account
    else
      self.save
    end
  end

  # Creates a hash with the methods
  def create_hash(*methods)
    Hash[ methods.map {|m| [m, self.send(m)] } ]
  end

  def show_exchange_rate?
    if to_id.present?
      if errors[:to_account].blank? and account.currency_id != to.currency_id
        true
      else
        false
      end
    else
      false
    end
  end

  def amount_currency
    begin
      er =  inverse? ? 1/exchange_rate : exchange_rate
      ( amount - interests_penalties ) * er
    rescue
      0
    end
  end

  def amount_interests_currency
    begin
      r = inverse? ? 1/exchange_rate : exchange_rate
      amount * r
    rescue
      0
    end
  end

  # Returns the amount
  #def account_amount
  #  if ac_id == account_id
  #    amount
  #  else
  #    -amount * exchange_rate
  #  end
  #end

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

  # Finds using the filter
  # @param Integer
  # @param String
  def self.filtered(ac_id, filter = 'all')
    ret = AccountLedger.where("account_id=:ac_id OR to_id=:ac_id", :ac_id => ac_id).includes(:account, :to)

    case filter
      when "nulled" then ret.nulled
      when "con"    then ret.con
      when "uncon"  then ret.pendent
      else "all"
        ret
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

  # Amount no interests
  def base_amount
    (amount - interests_penalties).abs
  end

  # Valid amount
  def valid_amount?
    if (out? or trans?) and account.amount < amount.abs
      errors[:base] << I18n.t("errors.messages.account_ledger.amount") 
      errors[:amount] << I18n.t("errors.messages.account_ledger.amount")
      false
    else
      true
    end
  end

private
  def set_currency
    self.currency_id = account_currency_id
  end

  def make_conciliation?
    make_conciliation === true
  end

  def set_code
    self.code = AccountLedger.count + 1
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
