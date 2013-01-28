class ExpenseQuery
  def initialize(rel = Expense)
    @rel = rel
  end

  # Used for exchange of services
  def exchange(contact_id)
    @rel.joins{transaction}.where(contact_id: contact_id)
    .where{(transaction.balance.gt 0) & (active.eq true) & (state.eq 'approved')}
  end
end
