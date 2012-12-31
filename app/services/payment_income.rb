# encoding: utf-8
class PaymentIncome < Payment
  # Creates the payment object
  def pay
    return false unless self.valid?

    res = true
    ActiveRecord::Base.transaction do
      update_income
      res = income.save
      res = create_ledger && res
      res = create_interest && res

      unless res
        set_errors(income, ledger, int_ledger)
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
      @ledger = build_ledger(amount: amount, operation: 'payin')
      @ledger.save
    else
      true
    end
  end

  def create_interest
    if interest.to_f > 0
      @int_ledger = build_ledger(amount: interest, operation: 'intin')
      @int_ledger.save
    else
      true
    end
  end

end
