# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::InventoryIn < Inventories::In
  attribute :income_id, Integer

  validates_presence_of :income
  validate :valid_quantities

  delegate :income_details, to: :income
  delegate :balance_inventory, :inventory_left, to: :income_calculations

  def income
    @income ||= Income.active.where(id: income_id).first
  end

  def build_details
    income.income_details.each do |det|
      unless det.balance === det.quantity
        inventory.inventory_details.build(item_id: det.item_id, quantity: 0)
      end
    end
  end

  def create
    res = true

    save do
      update_income_details
      update_income_balance

      income_errors.set_errors
      res = @income.save
      @inventory.account_id = income_id
      res = res && @inventory.save
      res && update_stocks
    end
  end

  def movement_detail(item_id)
    @income.details.find {|det| det.item_id === item_id }
  end

  private

    def operation
      'inc_in'
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

    def valid_items_ids
      details.all? {|v| income_item_ids.include?(v.item_id) }
    end

    def update_income_details
      details.each do |det|
        det_exp = movement_detail(det.item_id)
        det_exp.balance += det.quantity
      end
    end

    def update_income_balance
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
