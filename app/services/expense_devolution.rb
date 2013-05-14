# encoding: utf-8
# Creates a devolution that updates the Income#total and creates an
# instance of AccountLedger with the devolution data
class ExpenseDevolution < Devolution

  # Validations
  validates_presence_of :expense

  # Updates Exppense#balance and creates and AccountLedger object with the
  # devolution data
  def pay_back
    return false unless valid?

    commit_or_rollback do
      res = save_expense
      res = create_ledger

      set_errors(expense, ledger) unless res

      res
    end
  end

  def expense
    @expense ||= Expense.active.where(id: account_id).first
  end
  alias :transaction :expense

private
  def save_expense
    update_transaction
    err = ExpenseErrors.new(expense)
    err.set_errors

    expense.save
  end

  def create_ledger
    @ledger = build_ledger(
      amount: +amount, operation: 'devout', account_id: expense.id,
      status: get_status
    )
    @ledger.save_ledger
  end
end
