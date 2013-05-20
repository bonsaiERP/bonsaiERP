# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryIncome < InventoryOperationService
  attribute :income_id, Integer

  validates_presence_of :income
  validate :item_quantities

  delegate :income_details, to: :income

  def deliver
    return false unless valid?
    res = true
    commit_or_rollback do
      inventory_operation.ref_number = InventoryOperation.get_ref_number('InvI')
      inventory_operation.operation = 'inc_in'
      res = inventory_operation.save

      res = res && update_stocks {|st| st.quantity - item_quantity(st.item_id)}

      update_items {|it, det| det.balance - it.quantity }

      res = res && income.save
    end

    set_errors(inventory_operation) unless res

    res
  end

  def income
    @income ||= Income.find(income_id)
  end

private
  def update_items(&b)
    items.each do |it|
      det = income_detail(it.item_id)
      det.balance = b.call(it, det)
    end
  end

  def item_quantities
    valid = true
    items.each do |it|
      det = income_detail(it.item_id)
      if it.quantity > det.balance
        it.errors.add(:quantity, I18n.t('errors.messages.inventory_operation_detail.invalid_balance'))
        if valid
          self.errors.add(:base, '')
          valid = false
        end
      end
    end
  end

  def income_detail(item_id)
    income_details.find {|det| det.item_id === item_id }
  end
end
