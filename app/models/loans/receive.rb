# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Class for receiving loans
class Loans::Receive < Loan

  extend Models::AccountCode
  self.code_name = 'PR'

  has_one :ledger_in, -> { where(operation: 'lrcre') }, class_name: 'AccountLedger', foreign_key: :account_id

  def self.new(attrs = {})
    super { |loan| loan.name = get_code_number }
  end

  def create
    self.save && ledger.save_ledger
  end

  private

    def ledger
      @ledger ||= build_ledger_in(
        account_id: self.id,
        operation: 'lrcre',
        amount: amount,
        reference: 'FAKE'
      )
    end
end
