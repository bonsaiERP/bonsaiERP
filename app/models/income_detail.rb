# encoding: utf-8
class IncomeDetail < TransactionDetail

  # Relationships
  belongs_to :income, foreign_key: :account_id, conditions: {type: 'Income'}, inverse_of: :income_details

  # Validations
  validates_presence_of :income
end
