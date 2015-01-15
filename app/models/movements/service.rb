# Related logic for income and expense
class Movements::Service < Struct.new(:movement)
  attr_accessor :movement_history, :attributes_class

  # Delegates
  delegate :percentage, to: :tax, prefix: true
  delegate :tax_id, :tax_in_out?, :details, to: :movement
  delegate :set_details, to: :details_service
  delegate :direct_payment, :account_to_id, :reference, to: :attributes_class

  def create(attr_klass)
    @attributes_class = attr_klass
    @attributes_class.direct_payment = false
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
    @attributes_class.direct_payment = false
    set_update
    movement.save
  end

  def update_and_approve(attr_klass)
    @attributes_class = attr_klass
    set_update

    commit_or_rollback do
      movement.approve!
      movement.save && ledger.save_ledger
    end
  end

  def tax
    @tax ||= Tax.find_by(id: tax_id) || NullTax.new
  end

  private

    def set_update
      movement.attributes = get_update_attributes
      set_movement_extra_attributes
      Movements::Errors.new(movement).set_errors
    end

    def set_movement_extra_attributes
      set_details
      movement.total = calculate_total
      movement.tax_percentage = tax.percentage
      movement.balance = get_balance
      movement.balance_inventory = details_service.balance_inventory
      movement.state = get_state
      movement.delivered = details.all? { |d| d.balance <= 0 }
      #  Required for updates
      movement.extras = movement.extras.symbolize_keys
    end

    def get_balance
      if direct_payment?
        0
      else
        movement.balance - (movement.total_was - movement.total)
      end
    end

    def get_state
      case
      when movement.balance <= 0
        'paid'
      when movement.balance != movement.total
        'approved'
      else
        movement.state
      end
    end

    def calculate_total
      tot = details_service.subtotal #details.inject(0) { |s, d| s += d.subtotal  }
      tot += tot * tax.percentage/100  unless tax_in_out?
      tot
    end

    def today
      @today ||= Time.zone.now.to_date
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

    def get_update_attributes
      attributes_class.attributes.slice(
        :date, :due_date, :currency, :exchange_rate,
        :description, :project_id
      )
    end
end

# NullTax class
class NullTax
  def percentage
    0.0
  end
end
