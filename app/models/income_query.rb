# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomeQuery
  def initialize(rel = Income)
    @rel = rel
  end

  def inc
    @rel.includes(payments: [:account_to], income_details: [:item])
  end

  def search(params={})
    @rel.includes(:contact, transaction: [:creator, :approver])
  end

  def to_pay(contact_id)
    @rel.active.where{(state.eq 'approved') & (amount.gt 0)}.where(contact_id: contact_id)
  end
end
