# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgers::Query
  def initialize(rel = AccountLedger)
    @rel = rel
  end

  def money(id)
    @rel.where { (account_id.eq id) | (account_to_id.eq id) }
    .order('account_ledgers.date desc, account_ledgers.id desc')
    .includes(:contact, :account_to, :approver, :creator, :nuller, :updater)
  end

  def money_paged(id, page)
    money.page(page)
  end

  def payments(account_id)
    @rel.select(payment_columns(account_id).join(', '))
    .where('account_id=:id OR account_to_id=:id', id: account_id)
    .includes(:account, :account_to, :approver, :creator, :nuller, :updater)
  end

  def payments_ordered(account_id)
    payments(account_id).order('date desc, id desc')
  end

  private

    def payment_columns(account_id)
      AccountLedger.column_names + ["account_id=#{account_id} AS is_account"]
    end
end
