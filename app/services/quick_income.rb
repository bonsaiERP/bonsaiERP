# encoding: utf-8
class QuickIncome < QuickTransaction
  def create
    res = true
    ActiveRecord::Base.transaction do
      res = create_transaction

      res = create_ledger && res

      unless res
        set_errors(income, account_ledger)
        raise ActiveRecord::Rollback
      end
    end

    res
  end

  def income
    transaction
  end

private
  def create_transaction
    @transaction = Income.new(transaction_attributes) do |inc|
      inc.total = inc.gross_total = inc.original_total = amount
      inc.balance = 0
    end

    set_transaction_users

    @transaction.save
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
