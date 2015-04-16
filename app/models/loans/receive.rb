# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class for receiving loans
class Loans::Receive < Loan

  self.code_name = 'PR'

  # Relationships
  has_many :ledger_ins, -> { where(operation: 'lrcre') }, class_name: 'AccountLedger', foreign_key: :account_id

  has_many :payments, -> { where(operation: 'lrpay') }, class_name: 'AccountLedger', foreign_key: :account_id

  has_many :interest_ledgers, -> { where(operation: 'lrint') }, class_name: 'AccountLedger', foreign_key: :account_id

  def self.new(attrs = {})
    super { |loan| loan.name = get_code_number }
  end
end
