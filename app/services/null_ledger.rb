# encoding: utf-8
class NullLedger < Struct.new(:ledger)
  delegate :account, :account_to, :exchange_rate, :amount, to: :ledger

  def null_ledger
    case account.type
    when 'Income'
      update_account_amount
    when 'Expense'
      update_expense
    end
  end

private
  def update_ledger
    ledger.update_attributes(
      nuller_id: UserSession.id,
      active: false,
      nuller_datetime: Time.zone.now
    )
  end

  def update_account_amount
    res = true
    ActiveRecord::Base.transaction do
      account.amount += exchange.exchange(amount)
      res = account.save

      res = update_ledger

      raise ActiveRecord::Rollback unless res
    end

    res
  end

  def exchange
    @exchange ||= CurrencyExchange.new(account: account, account_to: account_to, exchange_rate: exchange_rate)
  end
end
