# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::InventoryOut < Inventories::Out
  attribute :income_id, Integer

  validates_presence_of :income
  validate :valid_quantities
  validate :valid_item_ids

  delegate :income_details, to: :income
  delegate :balance_inventory, :inventory_left, to: :income_calculations

  def income
    @income ||= Income.active.where(id: income_id).first
  end

  def build_details
    income.income_details.each do |det|
      inventory.inventory_details.build(item_id: det.item_id ,quantity: det.balance)
    end
    # Needed because the item_ids are set in the build
    inventory.inventory_details.each {|det| det.available = stock(det.item_id).quantity }
  end

  def create
    res = true

    save do
      update_income_details
      update_income_balanace
      income.operation_type = 'inventory_out'

      income_errors.set_errors
      res = income.save
      res = res && update_stocks
      Inventories::Errors.new(@inventory, stocks).set_errors
      @inventory.account_id = @income.id
      @inventory.contact_id = @income.contact_id
      res && @inventory.save
    end
  end

  def movement_detail(item_id)
    @income.details.find {|det| det.item_id === item_id }
  end

private

  def operation
    'inc_out'
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
    unless details.all? {|v| income_item_ids.include?(v.item_id) }
      self.errors.add(:base, I18n.t("errors.messages.inventory.movement_items"))
    end
  end

  def update_income_details
    details.each do |det|
      det_exp = movement_detail(det.item_id)
      det_exp.balance -= det.quantity
    end
  end

  def update_income_balanace
    @income.balance_inventory = balance_inventory
    @income.delivered = inventory_left === 0
  end

  def income_calculations
    @income_calculations ||= Movements::DetailsCalculations.new(@income)
  end

  def income_item_ids
    @income_item_ids ||= @income.details.map(&:item_id)
  end

  def income_errors
    @income_errors ||= Incomes::Errors.new(income)
  end
end
