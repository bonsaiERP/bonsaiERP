# encoding: utf-8
class QuickExpense < QuickTransaction
  def create
    res = true
    ActiveRecord::Base.transaction do
      res = create_transaction

      res = create_ledger && res

      unless res
        set_errors(expense, account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

  def expense
    transaction
  end

private
  def create_transaction
    @transaction = Expense.new(transaction_attributes) do |exp|
      exp.total = exp.gross_total = exp.original_total = amount
      exp.balance = 0
    end

    set_transaction_users

    @transaction.save
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

