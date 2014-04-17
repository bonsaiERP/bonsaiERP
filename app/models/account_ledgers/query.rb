# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgers::Query
  def initialize(rel = AccountLedger)
    @rel = rel
  end

  def money(id)
    @rel.where(t[:account_id].eq(id).or(t[:account_to_id].eq(id)))
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

  def search(search)
    s = "%#{search}%"
    AccountLedger
    .includes(:account, :account_to)
    .eager_load(:contact)
    .where { (account.name.like s) | (account_to.name.like s) | (contact.matchcode.like s) | (name.like s) }
  end

  private

    def payment_columns(account_id)
      AccountLedger.column_names + ["account_id=#{account_id} AS is_account"]
    end

    def t
      AccountLedger.arel_table
    end
end
