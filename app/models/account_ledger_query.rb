class AccountLedgerQuery
  def initialize(rel = AccountLedger.scoped)
    @rel = rel
  end

  def money(id)
    @rel.where{(account_id.eq id) | (account_to_id.eq id)}.order('date desc')
    .includes({account: :contact}, :account_to, :approver, :creator)
  end

  def money_paged(id, page)
    money.page(page)
  end
end
