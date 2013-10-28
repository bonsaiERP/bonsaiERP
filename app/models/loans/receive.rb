# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class for receiving loans
class Loans::Receive < Loan

  self.code_name = 'PR'

  has_one :ledger_in, -> { where(operation: 'lrcre') }, class_name: 'AccountLedger', foreign_key: :account_id

  def self.new(attrs = {})
    super { |loan| loan.name = get_code_number }
  end
end
