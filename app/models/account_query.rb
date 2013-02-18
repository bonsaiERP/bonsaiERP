class AccountQuery
  def initialize(rel = Account)
    @rel = rel
  end

  def bank_cash
    @rel.active.where(type: ['Cash', 'Bank'])
  end

  def bank_cash_options
    bank_cash.map {|v| create_hash(v, *default_options) }
  end

  def payment(model)
    #Account.where{(type.in ['Cash', 'Bank']) | (type: 'Expense')}
    bank_cash
  end

  def income_payment_options(income)
    bank_cash_options + ExpenseQuery.new.to_pay(income.contact_id).map {|v| 
      create_hash(v, *default_options)
    }
  end

  def expense_payment_options(expense)
    arr = bank_cash.map {|v| 
      create_hash(v, :id, :type, :currency, :amount, :name, :to_s) 
    }

    arr + IncomeQuery.new.to_pay(expense.contact_id).map {|v| 
      create_hash(v, :id, :type, :currency, :balance, :name, :to_s)
    }
  end

  def create_hash(v, *args)
    Hash[ args.map {|k| [k, v.send(k)] } ]
  end

  def default_options
    [:id, :type, :currency, :amount, :name, :to_s]
  end
end
