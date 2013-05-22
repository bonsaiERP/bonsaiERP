# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::InventoryOut < Movements::InventoryOut

  delegate :expense_details, to: :expense

  def expense
    @expense ||= Expense.active.where(id: account_id).first
  end
end
