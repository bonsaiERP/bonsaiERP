# encoding: utf-8
class IncomeDetail < TransactionDetail

  # Relationships
  belongs_to :income, foreign_key: :account_id, conditions: {type: 'Income'}, inverse_of: :income_details
  belongs_to :item, inverse_of: :income_details

  # Validations
  validates_presence_of :item
  validate :valid_income_item

  delegate :for_sale?, to: :item, prefix: true, allow_nil: true

private
  # TODO: Must create a link in the view to force the correction of the
  # item
  def valid_income_item
    self.errors[:item_id] << I18n.t('errors.messages.income_detail.item_not_for_sale') unless item_for_sale?
  end
end
