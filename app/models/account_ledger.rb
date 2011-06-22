# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  acts_as_org
  # callbacks
  before_validation { self.currency_id = account.try(:currency_id) unless currency_id.present? }

  # includes
  include Models::AccountLedger::Money

  OPERATIONS = %w(in out trans)
  OPERATIONS.each do |op|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{op}
        "#{op}" == op
      end
    CODE
  end

  # relationships
  belongs_to :account
  belongs_to :to, :class_name => "Account"
  belongs_to :transaction
  belongs_to :currency

  belongs_to :approver, :class_name => "User"
  belongs_to :nuller,   :class_name => "User"
  belongs_to :creator,  :class_name => "User"

  has_many :account_ledger_details, :dependent => :destroy
  accepts_nested_attributes_for :account_ledger_details

  # Validations
  validates_inclusion_of :operation, :in => OPERATIONS
  validates_numericality_of :amount, :greater_than => 0, :if => :new_record?
  validates_numericality_of :amount

  validates :reference, :length => { :within => 3..150, :allow_blank => false }
  validates :currency_id, :currency => true

  validate  :number_of_details
  validate  :total_amount_equal

  # accessible
  attr_accessible :account_id, :to_id, :date, :operation, :reference, :currency_id,
    :amount, :exchange_rate, :description, :account_ledger_details_attributes

  # scopes
  scope :pendent, where(:conciliation => false)
  scope :con,     where(:conciliation => true)
  scope :nulled,  where(:active => false)

  # delegates
  delegate :currency, :symbol, :to => :currency, :prefix => true 

  # metaprogramming options
  OPERATIONS.each do |v|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{v}?
        "#{v}" == operation
      end
    CODE
  end

  def self.pendent?
    pendent.count > 0
  end

  # Determines if the ledger can be nulled
  def can_destroy?
    not conciliation?
  end

  # Finds using the filter
  def self.filtered(filter)
    filter ||= 'all'

    case filter
      when "all"    then AccountLedger.scoped
      when "nulled" then AccountLedger.nulled
      when "con"    then AccountLedger.con
      when "uncon"  then AccountLedger.pendent
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
      self.errors[:base] << "Debe seleccionar al menos 2 cuentas" if account_ledger_details.size < 1
    end

end
