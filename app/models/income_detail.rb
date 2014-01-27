# encoding: utf-8
class IncomeDetail < MovementDetail

  # Relationships
  belongs_to :income, -> { where(type: 'Income') }, foreign_key: :account_id, inverse_of: :income_details
  belongs_to :item, inverse_of: :income_details

  # Validations
  validates_presence_of :item
  validate :valid_income_item, if: :item_id_changed?

  delegate :for_sale?, :to_s, :name,:price, to: :item, prefix: true, allow_nil: true

  private
    # item
    # Validates only when item_id changes, if the item has changed with
    # item.for_sale = false then it should be valid because it must
    # retain the original data from the form
    def valid_income_item
      self.errors[:item_id] << I18n.t('errors.messages.income_detail.item_not_for_sale') unless item_for_sale?
    end

    def balance_error_message
      I18n.t('errors.messages.income_details.balance')

    end
end
