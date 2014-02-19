# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that creates a inventory in "Devolution of items" for an Income
# this class inherits from Iventories::In < Inventories::Form
# inventory_details defined on Inventories::Form
class Incomes::InventoryIn < Inventories::In
  attribute :income_id, Integer
  attr_accessor :detail_quantity_diff

  validates_presence_of :income
  validate :valid_quantities

  delegate :income_details, to: :income
  delegate :balance_inventory, :inventory_left, to: :income_calculations

  def income
    @income ||= Income.active.where(id: income_id).first
  end

  def build_details
    available_income_details.each { |det| inventory_details.build(item_id: det.item_id, quantity: 0)  }
  end

  def create
    res = true

    save do
      res = update_income && save_inventory

    end
  end

  def movement_detail(item_id)
    @income.details.find {|det| det.item_id === item_id }
  end

  private

    def available_income_details
      @available_income_details ||= income_details.select { |det| det.balance != det.quantity }
    end

    def operation
      'inc_in'
    end

    def valid_quantities
      details.each do |det|
        if invalid_detail_quantity?(det)
          det.errors.add(:quantity, I18n.t('errors.messages.inventory.movement_quantity', q: detail_quantity_diff))
          set_has_error
        end
      end

      self.errors.add(:base, I18n.t('errors.messages.inventory.item_balance')) if has_error?
    end

    def invalid_detail_quantity?(det)
        mov_det = movement_detail(det.item_id)
        detail_quantity_diff = det.quantity - (mov_det.quantity - mov_det.balance)
        detail_quantity_diff > 0
    end

    def valid_items_ids
      details.all? {|det| income_item_ids.include?(det.item_id) }
    end

    def save_inventory
      inventory.account_id = income_id
      inventory.contact_id = income.contact_id
      inventory.save && update_stocks
    end

    def update_income
      update_income_details
      income.operation_type = 'inventory_in'
      income_errors.set_errors
      set_income_balance_and_delivered
      income.save
    end

    def update_income_details
      details.each do |det|
        det_exp = movement_detail(det.item_id)
        det_exp.balance += det.quantity
      end
    end

    def set_income_balance_and_delivered
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
