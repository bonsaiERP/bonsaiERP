class IncomeQuery
  def initialize(rel = Income)
    @rel = rel
  end

  def inc
    @rel.includes(payments: [:account_to], income_details: [:item])
  end

  def search(params={})
    @rel = @rel.where{} if params[:search].present?
    @rel.includes(:contact, transaction: [:creator, :approver])
  end

  def pay(contact_id)
    Expense.active.where{(state.eq 'approved') & (amount.gt 0)}.where(contact_id: contact_id)
  end
end
