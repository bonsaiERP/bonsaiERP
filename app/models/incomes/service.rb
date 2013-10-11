# Class that stores all requried methods for form save
class Incomes::Service < Movements::Service
  alias_method :income, :movement

  INCOME_ATTRIBUTES = ATTRIBUTES + [:income_details_attributes]
  DELEGATE = INCOME_ATTRIBUTES + EXTRA_METHODS + [:income_details]
  delegate(*DELEGATE, to: :income)

  def self.new_income(attrs = {})
    _object = new Income.new_income(attrs.slice(*INCOME_ATTRIBUTES))
    _object.set_defaults
    _object
  end

  def self.find_income(id)
    new Income.find(id)
  end

  def create
    set_movement_extra_attributes
    income.save
  end

  def create_and_approve
    @ledger = direct_payment? ? build_ledger : NullLedger.new
  end

  private

    def build_ledger
      @ledger = AccountLedger.new(
        account_id: income.id, amount: income.total,
        account_to_id: account_to_id, date: date,
        operation: 'payin', exchange_rate: 1,
        currency: income.currency, inverse: false,
        reference: get_reference
      )
    end
end
