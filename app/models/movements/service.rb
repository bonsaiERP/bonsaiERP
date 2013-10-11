# Related logic for income and expense
class Movements::Service
  attr_reader :movement, :ledger
  attr_accessor :direct_payment

  ATTRIBUTES = [:contact_id, :date, :due_date, :currency, :exchange_rate, :project_id, :description, :tax_id].freeze
  EXTRA_METHODS = [:details, :ref_number, :total, :balance]

  # Delegates
  delegate :percentage, to: :tax, prefix: true

  def initialize(mov)
    @movement = mov
  end

  def tax
    @tax ||= Tax.find_by(id: tax_id) || NullTax.new
  end

  def set_defaults
    movement.ref_number ||= @movement.class.get_ref_number
    movement.date ||= today
    movement.due_date ||= today
    movement.state = 'draft'
    movement.creator_id = UserSession.id
    movement.currency ||= OrganisationSession.currency
    build_movement_details
  end

  # Creates  and approves a Movement
  def create_and_approve
    @movement.approve!

    create
  end

  def direct_payment?
    !!direct_payment
  end

  private

    def set_movement_extra_attributes
      @movement.total = calculate_total
      @movement.tax_percentage = tax.percentage
      @movement.balance = @movement.balance + total
      @movement.creator_id = UserSession.id
    end

    def calculate_total
      tot = details.inject(0) { |s, d| s += d.subtotal  }
      tot += tot * tax.percentage
      tot
    end

    def today
      @today ||= Date.today
    end

    def build_movement_details
      2.times { movement.details.build(quantity: 1) }  if movement.details.empty?
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

    def balance_inventory
      details.inject(0) { |s, d| s += d.balance * d.price }
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
  def save_ledger
    true
  end
end
