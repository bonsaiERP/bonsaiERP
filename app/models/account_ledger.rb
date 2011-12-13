# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  # Constants
  OPERATIONS = %w(in out trans)
  BEHAVIORS = [:devolution, :payment, :transference, :inout]

  attr_reader *BEHAVIORS
  attr_reader :ac_id
  # Base amount is the #  amount = base_amount + interests_penalties
  attr_accessor :make_conciliation, :base_amount

  # callbacks
  before_validation :set_currency_id
  before_destroy    { false }
  #before_create     :set_code
  before_create     { self.creator_id = UserSession.user_id }

  # includes
  include ActionView::Helpers::NumberHelper

  # includes related to the model
  include Models::AccountLedger::Money
  include Models::AccountLedger::Transaction
  include Models::AccountLedger::Conciliation

  # Relationships
  belongs_to :account, :autosave => true
  belongs_to :to, :class_name => "Account", :autosave => true
  belongs_to :transaction
  belongs_to :currency
  belongs_to :contact

  belongs_to :approver, :class_name => "User"
  belongs_to :nuller,   :class_name => "User"
  belongs_to :creator,  :class_name => "User"

  has_many :account_ledger_details, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :account_ledger_details, :allow_destroy => true

  BEHAVIORS.each do |met|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{met}?; !!#{met}; end
    CODE
  end

  OPERATIONS.each do |op|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{op}?; "#{op}" == operation; end
    CODE
  end

  # Validations
  validates_presence_of :amount, :account_id, :reference

  validates_inclusion_of :operation, :in => OPERATIONS
  validates_numericality_of :amount, :greater_than => 0, :if => :new_record?
  validates_numericality_of :exchange_rate, :greater_than => 0

  validates :reference, :length => { :within => 3..150, :allow_blank => false }
  validates :currency_id, :currency => true
  #validates_uniqueness_of :code

  with_options :if => :devolution? do |opt|
    opt.before_create :set_amount
  end
  #validate  :number_of_details
  #validate  :total_amount_equal

  #attr_readonly :currency_id, :amount
  # accessible
  attr_accessible :account_id, :to_id, :date, :operation, :reference, :interests_penalties,
    :amount, :exchange_rate, :description, :account_ledger_details_attributes, :contact_id, :base_amount

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

  # delegates
  # currency
  delegate :name, :symbol, :code, :to => :currency, :prefix => true, :allow_nil => true
  # account
  delegate :currency_id, :name, :original_type, :accountable_type, :accountable, :amount, :accountable_id,
    :to => :account, :prefix => true, :allow_nil => true
  # to
  delegate :currency_id, :name, :original_type, :accountable_type, :accountable, :amount, :accountable_id,
    :to => :to, :prefix => true, :allow_nil => true
  # transaction
  delegate :type, :currency_id, :to => :transaction, :prefix => true, :allow_nil => true

 
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

  # Determines in or out depending the related account
  def in_out
    case
    when ( ac_id == account_id and amount > 0) then "in"
    when ( ac_id == account_id and amount < 0) then "out"
    when ( ac_id == to_id and amount > 0)      then "out"
    when ( ac_id == to_id and amount > 0)      then "in"
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
  def account_amount
    if ac_id == account_id
      amount
    else
      -amount * exchange_rate
    end
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

  # The sum should be equal
  def total_amount_equal
    tot = account_ledger_details.inject(0) {|sum, det| sum += det.amount_currency }
    unless tot == 0
      self.errors[:base] << "Existe un error en el balance"
    end
  end

  # There must be at least 2 account details
  def number_of_details
    self.errors[:base] << "Debe seleccionar al menos 2 cuentas" if account_ledger_details.size < 2
  end

  def set_currency_id
    self.currency_id = account_currency_id
  end

  def make_conciliation?
    make_conciliation === true
  end

  def set_code
    self.code = AccountLedger.count + 1
  end

end
