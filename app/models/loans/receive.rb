# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class for receiving loans
class Loans::Receive < Loan

  extend Models::AccountCode
  self.code_name = 'PR'

  def self.new(attrs = {})
    super { |loan| loan.name = get_code_number }
  end

  # Creates the loan and the related account_ledger
  def create_loan
    resp = true
    self.class.transaction do
      resp = Loan.save
      if resp
        AccountLedger.new(ledger_attributes)
      end
    end
  end

  private

    def ledger_attributes
      { amount: total, account_id: account_to_id }
    end
end
