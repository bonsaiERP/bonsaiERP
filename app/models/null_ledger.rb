# NullLedger class
class NullLedger
  attr_accessor :operation, :account_id
  def save_ledger
    true
  end

  def errors
    {}
  end
end

