# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::InventoryIn < Inventories::In
  attribute :expense_id, Integer

  validates_presence_of :expense
  validate :valid_quantities
  #validate :valid_item_ids

  delegate :expense_details, to: :expense
  delegate :balance_inventory, :inventory_left, to: :expense_calculations

  def expense
    @expense ||= Expense.active.where(id: expense_id).first
  end

  def build_details
    expense.expense_details.each do |det|
      inventory.inventory_details.build(item_id: det.item_id ,quantity: det.balance)
    end
  end

  def create
    res = true

    save do
      update_expense_details
      update_expense_balanace
      expense.operation_type = 'inventory_in'

      expense_errors.set_errors
      res = expense.save
      res = res && update_stocks
      Inventories::Errors.new(@inventory, stocks).set_errors
      @inventory.account_id = @expense.id
      @inventory.contact_id = @expense.contact_id
      res && @inventory.save
    end
  end

  def movement_detail(item_id)
    @expense.details.find {|det| det.item_id === item_id }
  end

  private

    def operation
      'exp_in'
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

    def valid_items_ids
      details.all? {|v| expense_item_ids.include?(v.item_id) }
    end

    def update_expense_details
      details.each do |det|
        det_exp = movement_detail(det.item_id)
        det_exp.balance -= det.quantity
      end
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

    def expense_errors
      @expense_errors ||= Expenses::Errors.new(expense)
    end
end
