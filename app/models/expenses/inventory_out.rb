# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::InventoryOut < Inventories::Out
  attribute :expense_id, Integer

  validates_presence_of :expense
  validate :valid_quantities
  validate :valid_item_ids

  delegate :expense_details, to: :expense
  delegate :balance_inventory, :inventory_left, to: :expense_calculations

  def expense
    @expense ||= Expense.active.where(id: expense_id).first
  end

  def create
    res = true

    save do
      update_expense_details
      update_expense_balance
      expense.operation_type = 'inventory_out'

      expense_errors.set_errors
      res = expense.save
      res = res && update_stocks
      Inventories::Errors.new(inventory, stocks).set_errors
      @inventory.account_id = expense_id
      @inventory.contact_id = expense.contact_id
      res = res && @inventory.save
    end
  end

  def build_details
    expense.expense_details.each do |det|
      unless det.balance === det.quantity
        inventory.inventory_details.build(item_id: det.item_id, quantity: 0)
      end
    end
    # Needed because the item_ids are set in the build
    inventory.inventory_details.each {|det| det.available = stock(det.item_id).quantity }
  end

  def movement_detail(item_id)
    @expense.details.find {|det| det.item_id === item_id }
  end

private
  def operation
    'exp_out'
  end

  def valid_quantities
    res = true
    details.each do |det|
      mov_det = movement_detail(det.item_id)
      mov_q = (mov_det.quantity - mov_det.balance)
      if det.quantity > mov_q
        det.errors.add(:quantity, I18n.t('errors.messages.inventory.movement_quantity', q: mov_q))
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
      det_exp.balance += det.quantity
    end
  end

  def update_expense_balance
    @expense.balance_inventory = balance_inventory
    @expense.delivered = inventory_left === 0
  end

  def expense_calculations
    @expense_calculations ||= Movements::DetailsCalculations.new(@expense)
  end

  def expense_item_ids
    @expense_item_ids ||= @expense.details.map(&:item_id)
  end

  def expense_errors
    @expense_errors ||= Expenses::Errors.new(expense)
  end
end
