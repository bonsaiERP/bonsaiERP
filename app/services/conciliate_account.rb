# author: Boris Barroso
# email: boriscyber@gmail.com
class ConciliateAccount
  attr_reader :account_ledger

  delegate :account, :account_to, :amount, :amount_currency,
           :approver_id, :nuller_id, :is_nulled?, to: :account_ledger

  def initialize(ledger)
    raise 'an AccountLedger instance was expected' unless ledger.is_a?(AccountLedger)
    @account_ledger = ledger
  end

  def conciliate
    return false unless can_conciliate?

    account_ledger.status = 'approved'
    update_account_ledger_approver

    case
    when is_service_payment?
      account_ledger.save
    when(is_inc_exp? || is_loan?)
      update_account_to
    else
      update_both_accounts
    end
  end

  def conciliate!
    res = true
    ActiveRecord::Base.transaction do
      res = conciliate
      raise ActiveRecord::Rollback unless res
    end

    res
  end

  private

    def is_inc_exp?
      %w(Income Expense).include?(account.class.to_s)
    end

    def is_loan?
     %w(Loans::Receive Loans::Give).include?(account.class.to_s)
    end

    # When an Income is payed with Expense or vice versa
    def is_service_payment?
      [Income, Expense].include?(account_to.class)
    end

    def update_account_to
      account_to.amount += amount

      account_to.save && account_ledger.save
    end

    def update_both_accounts
      account_to.amount += amount
      account.amount -= amount_currency

      res = account.save && account_to.save && account_ledger.save

      res
    end

    def update_account_ledger_approver
      account_ledger.approver_id = UserSession.id
      account_ledger.approver_datetime = Time.zone.now
    end

    def can_conciliate?
      res = !(approver_id.present? || is_nulled? || nuller_id.present?)
      account_ledger.errors.add(:base, I18n.t('errors.messages.account_ledger.approved')) unless res

      res
    end

    def account_is_income_or_expense?
      account.is_a?(Income) || account.is_a?(Expense)
    end
end