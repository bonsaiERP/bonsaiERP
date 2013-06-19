# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::Query < Movements::Query
  def initialize
    super Expense
  end

  def inc
    rel.includes(payments: [:account_to], expense_details: [:item])
  end

  def to_pay(contact_id)
    @rel.active.where{(state.eq 'approved') & (amount.gt 0)}.where(contact_id: contact_id)
  end
end
