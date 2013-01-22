# encoding: utf-8
class QuickExpense < QuickTransaction
  attr_reader :expense

  def create
    return false unless valid?
    res = true
    ActiveRecord::Base.transaction do
      res = create_expense

      res = create_ledger && res

      unless res
        set_errors(expense, account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

private
  def create_expense
    @expense = Expense.new_expense(transaction_attributes.merge(
      total: amount, gross_total: amount, original_total: amount, balance: 0,
      creator_id: UserSession.id, approver_id: UserSession.id
    ))

    @expense.save
  end

  def create_ledger
    @account_ledger = build_ledger(
      account_id: expense.id, operation: 'payout', amount: -amount,
      reference: "Egreso rápido #{expense.ref_number}"
    )

    @account_ledger.save_ledger
  end

  def ledger_amount
    -amount
  end

  def ledger_reference
    "Pago egreso #{expense.ref_number}"
  end

  def ledger_operation
    'payout'
  end

  def get_ref_number
    Expense.get_ref_number
  end
end

