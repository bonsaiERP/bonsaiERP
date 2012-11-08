# encoding: utf-8
class QuickExpense < QuickTransaction
  def expense
    transaction
  end

private
  def create_transaction
    @transaction = Expense.new(transaction_attributes) do |exp|
      exp.total = exp.gross_total = exp.original_total = amount
      exp.balance = amount
    end

    @transaction.save
  end

  def ledger_amount
    -amount
  end

  def ledger_reference
    "Pago egreso #{expense.ref_number}"
  end

  def ledger_operation
    'pout'
  end

  def get_ref_number
    Expense.get_ref_number
  end
end

