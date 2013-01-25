# encoding: utf-8
class IncomeDevolution < Devolution

  # Validations
  validates_presence_of :income
  validate :valid_income_total

  # Delegations
  delegate :total, :balance, to: :income, prefix: true, allow_nil: true

  # Creates the payment object
  def pay_back
    return false unless valid?

    res = true
    ActiveRecord::Base.transaction do
      res = save_income
      res = create_ledger && res

      unless res
        set_errors(income, ledger, int_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

  def income
    @transaction = @income ||= Income.find_by_id(account_id)
  end

private
  def save_income
    update_income

    income.save
  end

  def update_income
    income.balance += amount
    income.set_state_by_balance! # Sets state and the user
  end

  def create_ledger
    if amount.to_f > 0
      @ledger = build_ledger(
        amount: -amount, operation: 'devin', account_id: income.id,
        conciliation: conciliation?
      )
      @ledger.save_ledger
    else
      true
    end
  end

  # Indicates conciliation based on the type of account
  def conciliation?
    return true if conciliate?

    if account_to.is_a?(Bank)
      conciliate?
    else
      true
    end
  end

  def valid_income_total
    if ( amount.to_f + income_balance.to_f ) > income_total.to_f
      self.errors[:amount] << I18n.t('errors.messages.devolution.income_total')
    end
  end

end
