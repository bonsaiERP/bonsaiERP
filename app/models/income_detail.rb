# encoding: utf-8
class IncomeDetail < TransactionDetail

  # Relationships
  belongs_to :income, foreign_key: :account_id, conditions: {type: 'Income'}, inverse_of: :income_details

  # Validations
  validate :valid_income_item

  delegate :for_sale?, to: :item, prefix: true, allow_nil: true

private
  def valid_income_item
    self.errors[:item_id] << 'Debe seleccionar un ítem correcto' unless item_for_sale?
  end
end
