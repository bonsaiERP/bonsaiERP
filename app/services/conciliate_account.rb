# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ConciliateAccount
  attr_reader :account_ledger

  delegate :account, :account_to, :amount, :amount_currency, to: :account_ledger

  def initialize(ledger)
    raise 'an AccountLedger instance was expected' unless ledger.is_a?(AccountLedger)
    @account_ledger = ledger
  end

  def conciliate
    case account.class.to_s
    when 'Income', 'Expense'
      update_account_to
    else
      update_both_accounts
    end
  end
private
  def update_account_to
    account_to.amount += amount_currency
    account_ledger.approver_id = UserSession.id

    account_to.save && account_ledger.save
  end

  def update_both_accounts
    account.amount -= amount
    account_to.amount += amount_currency
    account_ledger.approver_id = UserSession.id

    account.save && account_to.save && account_ledger.save
  end
end
