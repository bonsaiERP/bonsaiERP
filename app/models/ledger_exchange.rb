# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class LedgerExchange < Struct.new(:account_ledger)
  delegate :amount, :inverse, :exchange_rate, to: :account_ledger

  def inverse
  end
end

