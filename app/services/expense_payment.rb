# encoding: utf-8
class ExpensePayment < Payment

  # Validations
  validates_presence_of :expense
  validate :valid_expense_balance

  # Delegations
  delegate :total, :balance, to: :expense, prefix: true, allow_nil: true

  # Creates the payment object
  def pay
    return false unless valid?

    res = true
    ActiveRecord::Base.transaction do
      res = save_expense
      res = create_ledger && res
      res = create_interest && res

      unless res
        set_errors(expense, ledger, int_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

  def expense
    @expense ||= Expense.find_by_id(account_id)
  end

private
  def save_expense
    update_expense
    expense.save
  end

  def update_expense
    expense.balance -= amount
    expense.set_state_by_balance!
  end

  def create_ledger
    if amount.to_f > 0
      @ledger = build_ledger(amount: amount, operation: 'payout', account_id: expense.id)
      @ledger.save_ledger
    else
      true
    end
  end

  def create_interest
    if interest.to_f > 0
      @int_ledger = build_ledger(amount: interest, operation: 'intout', account_id: expense.id)
      @int_ledger.save_ledger
    else
      true
    end
  end

  def valid_expense_balance
    if amount.to_f > expense_balance.to_f
      self.errors[:amount] << 'Ingreso una cantidad mayor que el balance'
    end
  end

end

