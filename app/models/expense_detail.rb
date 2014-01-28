# encoding: utf-8
# Class to store the details of a expense
class ExpenseDetail < MovementDetail

  # Relationships
  belongs_to :expense, -> { where(type: 'Expense') }, foreign_key: :account_id,
             inverse_of: :expense_details
  belongs_to :item, inverse_of: :expense_details

  delegate :for_sale?, :to_s, :name, :price, :buy_price, to: :item, prefix: true, allow_nil: true

  # Validations
  validates_presence_of :item
end
