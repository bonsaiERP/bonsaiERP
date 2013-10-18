# encoding: utf-8
class Incomes::QuickForm < QuickForm
  attr_reader :income

  def create
    return false unless valid?

    commit_or_rollback do
      res = create_income
      res = create_ledger && res

      set_errors(income, account_ledger) unless res

      res
    end
  end

private
  def create_income
    attrs = transaction_attributes.merge(
      ref_number: Income.get_ref_number,
      total: amount, gross_total: amount, original_total: amount, balance: 0,
      creator_id: UserSession.id, approver_id: UserSession.id
    )
    @transaction = @income = Income.new(attrs)
    @income.approve!
    @income.set_state_by_balance!

    @income.save
  end

  def create_ledger
    @account_ledger = build_ledger(
                        account_id: income.id, operation: 'payin', amount:amount,
                        reference: get_reference
                      )

    @account_ledger.save_ledger
  end

  def ledger_amount
    amount
  end

  def get_reference
    reference.present? ? reference : I18n.t('income.payment.reference', income: income)
  end

  def ledger_operation
    'payin'
  end
end
