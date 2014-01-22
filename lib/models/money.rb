module Models::Money
  def ledgers
    AccountLedgers::Query.new.money(id)
  end

  def pendent_ledgers
    ledgers.pendent
  end
end
