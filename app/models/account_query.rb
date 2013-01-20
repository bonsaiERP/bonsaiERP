class AccountQuery
  def initialize
    @rel = Account
  end

  def bank_cash
    @rel.where(type: ['Cash', 'Bank'], active: true)
  end

  def payment(model)
    bank_cash
  end
end
