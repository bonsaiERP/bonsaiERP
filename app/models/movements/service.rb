# Related logic for income and expense
class Movements::Service < Struct.new(:movement)
  attr_accessor :movement_history, :attributes_class

  # Delegates
  delegate :percentage, to: :tax, prefix: true
  delegate :tax_id, :details, to: :movement
  delegate :set_details, to: :details_service
  delegate :direct_payment, to: :attributes_class

  def create(attr_klass)
    @attributes_class = attr_klass
    set_movement_extra_attributes
    movement.save
  end

  def create_and_approve(attr_klass)
    @attributes_class = attr_klass

    commit_or_rollback do
      movement.approve!
      set_movement_extra_attributes

      movement.save && ledger.save_ledger
    end
  end

  def update(attr_klass)
    @attributes_class = attr_klass
    set_update
    movement.save && movement_history.save
  end

  def update_and_approve(attr_klass)
    @attributes_class = attr_klass
    set_update

    commit_or_rollback do
      res = movement_history.save
      res = movement.save && ledger.save_ledger && res
    end
  end

  def tax
    @tax ||= Tax.find_by(id: tax_id) || NullTax.new
  end

  private

    def set_update
      movement.attributes = get_update_attributes
      self.movement_history = TransactionHistory.new
      movement_history.set_history(movement)
      set_movement_extra_attributes
    end

    def set_movement_extra_attributes
      set_details
      movement.total = calculate_total
      movement.tax_percentage = tax.percentage
      movement.balance = movement.balance - (movement.total_was - movement.total)
      movement.balance_inventory = details_service.balance_inventory
      movement.state = 'paid'  if direct_payment?
    end

    def calculate_total
      tot = details.inject(0) { |s, d| s += d.subtotal  }
      tot += tot * tax.percentage
      tot
    end

    def today
      @today ||= Date.today
    end

    # Returns true if calls
    def commit_or_rollback(&b)
      res = true
      ActiveRecord::Base.transaction do
        res = b.call
        raise ActiveRecord::Rollback unless res
      end

      res
    end

    def details_service
      @details_service ||= Movements::Details.new(movement)
    end

    def direct_payment?
      direct_payment === true
    end

    def account_to
      @account_to ||= Account.find_by(id: account_to_id)
    end
end

# NullTax class
class NullTax
  def percentage
    0.0
  end
end

# NullLedger class
class NullLedger
  attr_accessor :operation, :account_id
  def save_ledger
    true
  end
end
