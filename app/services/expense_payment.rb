# encoding: utf-8
class ExpensePayment < Payment

  # Validations
  validates_presence_of :expense
  validate :valid_expense_balance
  validate :valid_account_to_balance, if: :account_to_is_income?
  validate :valid_account_to_state, if: :account_to_is_income?

  # Delegations
  delegate :total, :balance, to: :expense, prefix: true, allow_nil: true

  # Creates the payment updating related objects
  def pay
    return false unless valid?

    commit_or_rollback do
      res = save_expense
      res = save_income if account_to_is_income?
      res = create_ledger && res
      res = create_interest && res

      set_errors(expense, ledger, int_ledger) unless res

      res
    end
  end

  def expense
    @transaction = @expense ||= Expense.find_by_id(account_id)
  end
  alias_method :transaction, :expense

private
  def save_expense
    update_expense

    expense.save
  end

  def update_expense
    expense.balance -= amount_exchange
    expense.set_state_by_balance!
  end

  # Updates the expense and sets it's state
  # Service exchange
  def save_income
    account_to.balance -= amount + interest
    account_to.set_state_by_balance!

    account_to.save
  end

  def create_ledger
    if amount.to_f > 0
      @ledger = build_ledger(
                  amount: -amount, operation: 'payout', account_id: expense.id,
                  conciliation: conciliation?
                )
      @ledger.save_ledger
    else
      true
    end
  end

  def create_interest
    if interest.to_f > 0
      @int_ledger = build_ledger(
                      amount: -interest, operation: 'intout',
                      account_id: expense.id, conciliation: conciliation?
                    )
      @int_ledger.save_ledger
    else
      true
    end
  end

  def valid_expense_balance
    if amount_exchange.to_f > expense_balance.to_f
      self.errors.add :amount, I18n.t('errors.messages.payment.balance')
    end
  end

  def account_to_is_income?
    account_to.is_a?(Income)
  end

  # Only when you pay with a income
  def valid_account_to_balance
    if account_to.balance < (amount + interest)
      self.errors.add :amount, I18n.t('errors.messages.payment.income_balance')
    end
  end

  def valid_account_to_state
    self.errors.add(:account_to_id, I18n.t('errors.messages.payment.invalid_income_state')) unless account_to.is_approved?
  end

end
