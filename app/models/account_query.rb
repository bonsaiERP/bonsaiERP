class AccountQuery
  def initialize(rel = Account)
    @rel = rel
  end

  def bank_cash
    @rel.active.where(type: ['Cash', 'Bank']).includes(:moneystore)
  end

  def bank_cash_options
    blank + bank_cash.map {|v| create_hash(v, *default_options) }
  end

  def bank_cash_options_minus(*ids)
    blank + bank_cash.where("id NOT in (?)", ids).map {|v| create_hash(v, *default_options) }
  end

  def income_payment_options(income)
    bank_cash_options + Expense.approved.where(contact_id: income.contact_id).map {|v| 
      create_hash(v, *default_options)
    }
  end

  def expense_payment_options(expense)
    bank_cash_options + Income.approved.where(contact_id: expense.contact_id).map {|v| 
      create_hash(v, *default_options)
    }
  end

  def create_hash(v, *args)
    Hash[ args.map {|k| [k, v.send(k)] } ]
  end

  def default_options
    [:id, :type, :currency, :amount, :name, :to_s]
  end

  def blank
    [{}]
  end

end
