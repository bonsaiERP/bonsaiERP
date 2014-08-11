# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::Payment < PaymentService

  # Validations
  validates_presence_of :expense
  validate :valid_expense_balance
  validate :valid_account_to_balance, if: :account_to_is_income?
  validate :valid_account_to_state, if: :account_to_is_income?

  # Delegations
  delegate :total, :balance, :currency, to: :expense, prefix: true, allow_nil: true

  # Creates the payment updating related objects
  def pay
    return false unless valid?

    commit_or_rollback do
      res = save_expense
      res = save_income if account_to_is_income?
      res = create_ledger && res

      set_errors(expense, ledger) unless res

      res
    end
  end

  def expense
    @movement = @expense ||= Expense.find_by_id(account_id)
  end
  alias_method :movement, :expense

  private

    def save_expense
      update_expense

      expense.save
    end

    def update_expense
      expense.approve!
      expense.balance -= amount_exchange.round(2)
      expense.set_state_by_balance!
      expense.operation_type = 'ledger_out'
    end

    # Updates the expense and sets it's state
    # Service exchange
    def save_income
      account_to.balance -= amount
      account_to.set_state_by_balance!

      account_to.save
    end

    def create_ledger
      if amount > 0
        @ledger = build_ledger(
                    amount: -amount, operation: get_operation,
                    account_id: expense.id, status: get_status,
                    contact_id: expense.contact_id
                  )
        @ledger.save_ledger
      else
        true
      end
    end

    def valid_expense_balance
      if complete_accounts? && amount_exchange > movement_balance
        self.errors.add :amount, I18n.t('errors.messages.payment.balance')
      end
    end

    def get_operation
      account_to.is_a?(Income) ? 'servin' : 'payout'
    end

    def account_to_is_income?
      account_to.is_a?(Income)
    end

    # Only when you pay with a income
    def valid_account_to_balance
      self.errors.add :amount, I18n.t('errors.messages.payment.income_balance') if account_to.balance < amount
    end

    def valid_account_to_state
      self.errors.add(:account_to_id, I18n.t('errors.messages.payment.invalid_income_state')) unless account_to.is_approved?
    end
end
