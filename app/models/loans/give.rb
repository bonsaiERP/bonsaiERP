# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class for receiving loans
class Loans::Give < Loan

  self.code_name = 'PG'

  # Relationships
  has_many :ledger_ins, -> { where(operation: 'lgcre') }, class_name: 'AccountLedger', foreign_key: :account_id

  has_many :payments, -> { where(operation: 'lgpay') }, class_name: 'AccountLedger', foreign_key: :account_id
  has_many :interest_ledgers, -> { where(operation: 'lgint') }, class_name: 'AccountLedger', foreign_key: :account_id

  def self.new(attrs = {})
    super { |loan| loan.name = get_code_number }
  end
end
