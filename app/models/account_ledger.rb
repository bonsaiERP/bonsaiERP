# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  # callbacks
  before_validation { self.currency_id = account.try(:currency_id) }

  attr_accessible :account_id, :to_id, :date, :operation, :reference, :currency_id,
    :amount, :exchanege_rate, :description, :account_ledger_details_attributes

  OPERATIONS = %w(in out trans)

  # relationships
  belongs_to :account
  belongs_to :to, :class_name => "Account"

  has_many :account_ledger_details, :dependent => :destroy
  accepts_nested_attributes_for :account_ledger_details

  # Validations
  validates_inclusion_of :operation, :in => OPERATIONS
  validates_numericality_of :amount, :greater_than => 0

  validates :reference, :length => { :within => 3..150, :allow_blank => false }
  validates :currency_id, :currency => true

  validate  :number_of_details
  validate  :total_amount_equal

  include Models::AccountLedger::Money

  # metaprogramming options
  OPERATIONS.each do |v|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{v}?
        "#{v}" == operation
      end
    CODE
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
