#encoding: utf-8
module Models::Loan::Approve
  extend ActiveSupport::Concern

  def approve_loan
    ret = true
    self.class.transaction do
      self.balance = total
      self.pay_plans.build(due_date: Date.today, amount: self.total)

      al = self.build_account_ledger(
        amount: balance,
        account_id: account_id,
        reference: create_reference,
        operation: ledger_operation,
        exchange_rate: 1,
        currency_id: currency_id
      )
      al.conciliation = true
      al.status = "loan_first"

      ret = self.save
      ret = ret && update_related_accounts
      raise ActiveRecord::Rollback unless ret
    end

    ret
  end

  def create_reference
    "#{reference_title} por prestamo #{ref_number}"
  end

  def update_related_accounts
    if self.is_a?(Loanin)
      self.account.amount += balance
      contact_ac = self.contact.account_cur(currency_id)
      contact_ac.amount += -balance
    else
    end
      
    self.account.save && contact_ac.save
  end
end
