# encoding: utf-8
# Creates a devolution that updates the Income#total and creates an
# instance of AccountLedger with the devolution data
class Expenses::Devolution < Devolution

  # Validations
  validates_presence_of :expense

  # Delegations
  delegate :total, :balance, :currency, to: :expense, prefix: true, allow_nil: true

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
  alias :movement :expense

  private

    def save_expense
      update_movement
      err = Expenses::Errors.new(expense)
      err.set_errors
      expense.operation_type = 'ledger_in'

      expense.save
    end

    def create_ledger
      @ledger = build_ledger(
        amount: +amount, operation: 'devout', account_id: expense.id,
        status: get_status, contact_id: expense.contact_id
      )
      @ledger.save_ledger
    end
end
