# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::InventoryOut < Inventories::Out
  attribute :account_id, Integer

  validates_presence_of :expense
  validate :valid_quantities
  validate :valid_item_ids
  
  delegate :expense_details, to: :expense
  delegate :balance_inventory, :inventory_left, to: :expense_calculations

  def expense
    @expense ||= Expense.active.where(id: account_id).first
  end

  def create
    res = true

    save do
      update_expense_details
      update_expense_balanace

      res = @expense.save
      res = res && @inventory.save
      res && update_stocks
    end
  end

private
  def operation
    'exp_out'
  end

  def valid_quantities
    res = true
    details.each do |det|
      if det.quantity > movement_detail(det.item_id).balance
        det.errors.add(:quantity, I18n.t('errors.messages.inventory.movement_quantity'))
        res = false
      end
    end

    self.errors.add(:base, I18n.t('errors.messages.inventory.item_balance')) unless res
  end

  def valid_item_ids
    unless details.all? {|v| expense_item_ids.include?(v.item_id) }
      self.errors.add(:base, I18n.t("errors.messages.inventory.movement_items"))
    end
  end

  def update_expense_details
    details.each do |det|
      det_exp = movement_detail(det.item_id)
      det_exp.balance -= det.quantity
    end
  end

  def movement_detail(item_id)
    @expense.details.find {|det| det.item_id === item_id }
  end

  def update_expense_balanace
    @expense.balance_inventory = balance_inventory
    @expense.delivered = inventory_left === 0
  end

  def expense_calculations
    @expense_calculations ||= Movements::DetailsCalculations.new(@expense)
  end

  def expense_item_ids
    @expense_item_ids ||= @expense.details.map(&:item_id)
  end
end
