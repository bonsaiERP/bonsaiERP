# encoding: utf-8
class ExpenseDetail < TransactionDetail

  # Relationships
  belongs_to :expense, foreign_key: :account_id, conditions: {type: 'Expense'}, inverse_of: :expense_details
  belongs_to :item, inverse_of: :expense_details

  # Validations
  validates_presence_of :item
end

