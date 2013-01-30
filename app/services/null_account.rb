# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class NullAccount
  attr_reader :account_ledger

  delegate :account, :account_to, :amount, :amount_currency, to: :account_ledger

  def initialize(ledger)
    raise 'an AccountLedger instance was expected' unless ledger.is_a?(AccountLedger)
    @account_ledger = ledger
  end

  def null
    return false unless valid?

    account_ledger.active = false
    set_account_ledger_nuller

    res = true

    case account.class.to_s
    when 'Income','Expense'
      res = update_account_balance
    else
      res = update_account
    end

    res && account_ledger.save
  end

  def null!
    res = true
    ActiveRecord::Base.transaction do
      res = null

      raise ActiveRecord::Rollback unless res
    end

    res
  end

  def valid?
    account_ledger.active? && !account_ledger.conciliation?
  end

private
  def update_account_balance
    account.balance += amount_currency
    account.set_state_by_balance!

    account.save
  end

  def update_account
    account.amount += amount_currency

    account.save
  end

  def set_account_ledger_nuller
    account_ledger.nuller_id = UserSession.id
    account_ledger.nuller_datetime = Time.zone.now
  end
end
