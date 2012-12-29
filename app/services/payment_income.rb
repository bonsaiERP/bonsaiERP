# encoding: utf-8
class PaymentIncome < Payment
  # Creates the payment object
  def pay
    res = true
    ActiveRecord::Base.transaction do
      update_income
      res = income.save
      res = create_ledger && res
      res = create_interest && res
      res = ledger.save && res

      unless res
        # TODO set_errors
        raise ActiveRecord::Rollback
      end
    end

    res
  end

  def income
    transaction
  end

private
  def trans_class
    Income
  end

  def update_income
    income.balance -= amount
    set_state
  end

  def set_state
    if income.balance <= 0
      income.state = 'paid'
    else
      income.state = 'approved'
    end
  end

  def create_ledger
    if amount.to_f > 0
      @ledger = AccountLedger.new(
        transaction_id: transaction_id, operation: 'payin',
        amount: amount, conciliation: verification, account_id: account_id,
        contact_id: income.contact_id
      )

      @ledger.save
    else
      true
    end
  end

  def create_interest
    if interest.to_f > 0
      @int_ledger = AccountLedger.new(
        transaction_id: transaction_id, operation: 'intin',
        amount: interest, conciliation: false, account_id: account_id,
        contact_id: income.contact_id
      )

      @int_ledger.save
    else
      true
    end
  end

end
