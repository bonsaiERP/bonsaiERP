# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Sets and Income or expense
class MovementService
  attr_reader :errors, :klass, :movement
  ATTRIBUTES = [:date, :due_date, :contact_id, :total, :currency, :exchange_rate, :project_id, :due_date, :description].freeze

  delegate :discount, :total, to: :movement
  delegate :set_details, to: :mov_details
  delegate :original_total, :balance_inventory, to: :calculations

  def initialize(mov)
    @movement = mov
    if @movement.is_a?(Income)
      set_income
    else
      set_expense
    end
  end

  def set_new(attrs = {})
    today = Date.today
    @movement.attributes = attrs.slice(*attributes).merge(
      ref_number: @klass.get_ref_number,
      date: attrs[:date] || today,
      due_date: attrs[:due_date] || today,
      state: 'draft',
      creator_id: UserSession.id,
      currency: attrs[:currency] || OrganisationSession.currency
    )

    set_details
    @movement.gross_total = original_total
    @movement.discounted = (discount > 0)
    #@movement.balance = total
    @movement.balance_inventory = balance_inventory

    2.times { @movement.details.build(quantity: 1) }  if @movement.details.empty?
  end

  # Updates the data for an imcome or expense
  # balance is the alias for amount due that Income < Account
  def set_update(attrs = {})
    @movement.attributes = attrs.slice(*attributes_for_update)
    set_details

    @movement.balance     = get_updated_balance
    @movement.gross_total = original_total
    @movement.set_state_by_balance!
    @movement.discounted  = ( discount > 0 )

    @movement.balance_inventory = balance_inventory
    @movement.delivered = @movement.details.all? {|v| v.balance <= 0}

    @errors.new(movement).set_errors
  end

  private

    def set_income
      @klass   = Income
      @errors  = Incomes::Errors
      @details = :income_details_attributes
    end

    # To eliminate NaN
    def get_updated_balance
      tot_was = @movement.total_was.to_s === "NaN" ? 0 : @movement.total_was
      tot = @movement.total.to_s === "NaN" ? 0 : @movement.total
      bal = @movement.balance.to_s === "NaN" ? 0 : @movement.balance
      bal - (tot_was - tot.round(2))
    end

    def set_expense
      @klass   = Expense
      @errors  = Expenses::Errors
      @details = :expense_details_attributes
    end

    def attributes
      ATTRIBUTES + [@details]
    end

    def attributes_for_update
      attributes.reject {|v| v === :contact_id}
    end

    def details_calculations
      @details_calculations ||= Movements::DetailsCalculation.new(@movement)
    end

    def mov_details
      @mov_details ||= Movements::Details.new(@movement)
    end

    def calculations
      @calculations ||= Movements::DetailsCalculations.new(@movement)
    end
end
