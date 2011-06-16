# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedger < ActiveRecord::Base

  # callbacks
  before_validation :set_operation, :if => :new_record?

  attr_protected :conciliation

  attr_accessor :operation, :amount

  OPERATIONS = %w(in out trans)

  has_many :account_ledger_details, :dependent => :destroy
  accepts_nested_attributes_for :account_ledger_details

  validates_inclusion_of :operation, :in => OPERATIONS
  validate :number_of_details
  validate :total_amount_equal

  # metaprogramming options
  OPERATIONS.each do |v|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{v}?
        "#{v}" == operation
      end
    CODE
  end

  # Instances a new money account
  def self.new_money(params)
    ac = AccountLedger.new(params)
    ac.extend Models::AccountLedger::Money

    ac
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

  # Sets the operation for the details
  def set_operation
    account_ledger_details.each {|det| det.operation = operation }
  end
end
