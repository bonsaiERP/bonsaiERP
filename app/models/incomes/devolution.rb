# encoding: utf-8
# Creates a devolution that updates the Income#total and creates an
# instance of AccountLedger with the devolution data
class Incomes::Devolution < Devolution

  # Validations
  validates_presence_of :income

  # Delegations
  delegate :total, :balance, :currency, to: :income, prefix: true, allow_nil: true

  # Updates Income#total and creates and AccountLedger object with the
  # devolution data
  def pay_back
    return false unless valid?

    commit_or_rollback do
      res = save_income && create_ledger
      set_errors(income, ledger) unless res

      res
    end
  end

  def income
    @income ||= Income.active.where(id: account_id).first
  end
  alias :movement :income

  private

    def save_income
      update_movement
      err = Incomes::Errors.new(income)
      err.set_errors
      income.operation_type = 'ledger_out'

      income.save
    end

    def create_ledger
      @ledger = build_ledger(
        amount: -amount, operation: 'devin', account_id: income.id,
        status: get_status, contact_id: income.contact_id
      )
      @ledger.save_ledger
    end
end
