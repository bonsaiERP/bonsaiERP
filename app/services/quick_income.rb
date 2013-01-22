# encoding: utf-8
class QuickIncome < QuickTransaction
  attr_reader :income

  def create
    return false unless valid?
    res = true
    ActiveRecord::Base.transaction do
      res = create_income

      res = create_ledger && res

      unless res
        set_errors(income, account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

private
  def create_income
    @income = Income.new_income(transaction_attributes.merge(
      total: amount, gross_total: amount, original_total: amount, balance: 0,
      creator_id: UserSession.id, approver_id: UserSession.id
    ))

    @income.save
  end

  def create_ledger
    @account_ledger = build_ledger(
      account_id: income.id, operation: 'payin', amount:amount,
      reference: "Ingreso rápido #{income.ref_number}"
    )

    @account_ledger.save_ledger
  end

  def ledger_amount
    amount
  end

  def ledger_reference
    "Cobro ingreso #{income.ref_number}"
  end

  def ledger_operation
    'payin'
  end

  def get_ref_number
    Income.get_ref_number
  end
end
