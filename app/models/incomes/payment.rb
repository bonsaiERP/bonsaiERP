# encoding: utf-8
class Incomes::Payment < PaymentService

  # Validations
  validates_presence_of :income
  validate :valid_account_to_balance, if: :account_to_is_expense?
  validate :valid_account_to_state, if: :account_to_is_expense?
  validate :valid_amount

  # Delegations
  delegate :total, :balance, :currency, to: :income, prefix: true, allow_nil: true

  # Makes the payment modifiying the Income and creatinig AccountLedger
  def pay
    return false unless valid?

    commit_or_rollback do
      res = save_income
      res = save_expense if account_to_is_expense?
      res = create_ledger && res

      set_errors(*[income, ledger].compact) unless res

      res
    end
  end

  def income
    @movement = @income ||= Income.find_by_id(account_id)
  end
  alias :movement :income

  private

    def save_income
      update_income
      err = Incomes::Errors.new(income)
      err.set_errors
      income.operation_type = 'ledger_in'
      income.save
    end

    def update_income
      income.approve!
      income.amount -= amount_exchange.round(2)
      income.set_state_by_balance! # Sets state and the user
    end

    # Updates the expense and sets it's state
    # Service exchange
    def save_expense
      account_to.amount -= amount
      account_to.set_state_by_balance!

      account_to.save
    end

    def create_ledger
      @ledger = build_ledger(
                  amount: amount, operation: get_operation, account_id: income.id,
                  status: get_status, contact_id: income.contact_id
                )

      @ledger.save_ledger
    end

    def account_to_is_expense?
      account_to.is_a?(Expense)
    end

    def get_operation
      account_to_is_expense? ? 'servex' : 'payin'
    end

    # Only when you pay with a expense
    def valid_account_to_balance
      if account_to.balance < amount
        self.errors.add :amount, I18n.t('errors.messages.payment.expense_balance')
      end
    end

    def valid_account_to_state
      self.errors.add(:account_to_id, I18n.t('errors.messages.payment.invalid_expense_state')) unless account_to.is_approved?
    end
end
