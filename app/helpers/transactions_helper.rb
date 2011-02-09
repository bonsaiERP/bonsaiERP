# encoding: utf-8
module TransactionsHelper
  def cash(cash)
    if cash
      "al contado"
    else
      "a crédito"
    end
  end
end
