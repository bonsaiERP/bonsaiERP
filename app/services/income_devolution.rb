# encoding: utf-8
# Creates a devolution that updates the Income#total and creates an
# instance of AccountLedger with the devolution data
class IncomeDevolution < Devolution

  # Validations
  validates_presence_of :income
  validate :valid_income_total

  # Delegations
  delegate :total, :balance, to: :income, prefix: true, allow_nil: true

  # Updates Income#total and creates and AccountLedger object with the
  # devolution data
  def pay_back
    return false unless valid?

    commit_or_rollback do
      res = save_income
      res = create_ledger

      set_errors(income, ledger) unless res

      res
    end
  end

  def income
    @transaction = @income ||= Income.find_by_id(account_id)
  end

private
  def save_income
    update_income
    err = IncomeErrors.new(income)
    err.set_errors

    income.save
  end

  def update_income
    income.balance += amount
    income.set_state_by_balance! # Sets state and the user
  end

  def create_ledger
    @ledger = build_ledger(
                            amount: -amount, operation: 'devin', account_id: income.id,
                            conciliation: conciliation?
                          )
    @ledger.save_ledger
  end

  # Indicates conciliation based on the type of account
  def conciliation?
    return true if conciliate?

    account_to.is_a?(Bank) ? conciliate? : true
  end

  def valid_income_total
    if ( amount.to_f + income_balance.to_f ) > income_total.to_f
      self.errors.add :amount, I18n.t('errors.messages.devolution.income_total')
    end
  end

end
