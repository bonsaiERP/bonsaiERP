#encoding: utf-8
module Models::Loan::Approve
  extend ActiveSupport::Concern

  def approve_loan
    ret = true
    self.class.transaction do
      self.pay_plans.build(due_date: Date.today, amount: self.total)
      al = self.account_ledgers.build(amount: balance, 
                          account_id: account_id,
                          reference: "First",
                          operation: ledger_operation,
                          exchange_rate: 1,
                          currency_id: currency_id
                      )
      ret = self.save
      puts "Con: #{al.can_conciliate?}"
      puts "#{al.active?} :: #{al.conciliation?}"
      ret = al.conciliate_account && ret
      raise ActiveRecord::Rollback unless ret
    end

    ret
  end
end
