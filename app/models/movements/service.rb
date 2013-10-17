# Related logic for income and expense
class Movements::Service < Struct.new(:movement)
  PAYMENT_ATTRIBUTES = [:direct_payment, :account_to_id, :reference]
  attr_accessor(*(PAYMENT_ATTRIBUTES + [:history]))

  # Delegates
  delegate :percentage, to: :tax, prefix: true
  delegate :tax_id, :details, to: :movement
  delegate :set_details, to: :details_service

  def tax
    @tax ||= Tax.find_by(id: tax_id) || NullTax.new
  end

  def create
    set_movement_extra_attributes
    movement.save
  end

  def create_and_approve(attrs = {})
    set_payment_attributes attrs

    commit_or_rollback do
      movement.approve!
      set_movement_extra_attributes

      movement.save && ledger.save_ledger
    end
  end

  def update(attrs = {})
    set_update(attrs)
    movement.save && history.save
  end

  def update_and_approve(attrs = {})
    set_update(attrs.except(:direct_payment, :account_to_id))
    set_payment_attributes attrs

    commit_or_rollback do
      res = history.save
      res = movement.save && ledger.save_ledger && res
    end
  end

  private

    def set_update(attrs)
      attrs.delete(:contact_id)
      @history = TransactionHistory.new
      @history.set_history(movement)
      movement.attributes = attrs
      set_movement_extra_attributes
    end

    def set_movement_extra_attributes
      set_details
      movement.total = calculate_total
      movement.tax_percentage = tax.percentage
      movement.balance = movement.balance - (movement.total_was - movement.total)
      movement.balance_inventory = details_service.balance_inventory
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

    def set_payment_attributes(attrs)
      PAYMENT_ATTRIBUTES.each { |k| self.send(:"#{k}=", attrs[k]) }
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
