#encoding: utf-8
module Models::Loan::Approve
  extend ActiveSupport::Concern

  def approve_loan
    ret = true
    self.class.transaction do
      self.pay_plans.build(due_date: Date.today, amount: self.total)
      al = self.account_ledgers.build(amount: balance, 
                          account_id: account_id,
                          reference: create_reference,
                          operation: ledger_operation,
                          exchange_rate: 1,
                          currency_id: currency_id
                      )
      al.conciliation = false
      ret = self.save
      ret = al.conciliate_account && ret
      raise ActiveRecord::Rollback unless ret
    end

    ret
  end

  def create_reference
    "#{reference_title} por prestamo #{ref_number}"
  end
end
