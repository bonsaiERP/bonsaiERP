class AccountQuery
  class << self
    def bank_cash
      Account.where(type: ['Cash', Bank], active: true)
    end
  end
end
