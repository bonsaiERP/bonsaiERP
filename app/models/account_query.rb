class AccountQuery
  def initialize
    @rel = Account
  end

  def bank_cash
    Account.where(type: ['Cash', 'Bank'], active: true)
  end
end
