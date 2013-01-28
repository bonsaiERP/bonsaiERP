class AccountQuery
  def initialize(rel = Account)
    @rel = rel
  end

  def bank_cash
    @rel.where(type: ['Cash', 'Bank'], active: true)
  end

  def payment(model)
    model.contact_id
    Account.where{(type.in ['Cash', 'Bank']) | (type: 'Expense')}
    bank_cash
  end
end
