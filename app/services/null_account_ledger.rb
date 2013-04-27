# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class NullAccountLedger
  attr_reader :account_ledger

  delegate :account, :account_to, :amount, :amount_currency,
           :nuller_id, :approver_id,  to: :account_ledger

  def initialize(ledger)
    raise 'an AccountLedger instance was expected' unless ledger.is_a?(AccountLedger)
    @account_ledger = ledger
  end

  def null
    return false unless valid?

    set_account_ledger_null

    res = case account.class.to_s
          when 'Income','Expense'
            res = update_income_expense_balance
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
    !(nuller_id.present? || approver_id.present?)
  end

private
  def update_income_expense_balance
    account.amount += amount_currency.round(2)
    account.set_state_by_balance!

    if account.is_a?(Income)
      IncomeErrors.new(account).set_errors
    elsif account.is_a?(Expense)
    end

    account.save
  end

  def update_account
    account.amount += amount_currency

    account.save
  end

  def set_account_ledger_null
    account_ledger.nuller_id       = UserSession.id
    account_ledger.nuller_datetime = Time.zone.now
    account_ledger.status          = 'nulled'
  end
end
