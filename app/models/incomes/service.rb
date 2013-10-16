# Class that stores all requried methods for form save
# 1 Saves common data Cotact details etc
# 2 Set the balance
# 3 Create ledger if direct_payment
# 4 Set item balance
# 5 Set errors for income
class Incomes::Service < Movements::Service
  alias_method :income, :movement

  INCOME_ATTRIBUTES = ATTRIBUTES + [:income_details_attributes]
  DELEGATE = INCOME_ATTRIBUTES + EXTRA_METHODS + [:income_details]

  delegate(*DELEGATE, to: :income)
  delegate :income, to: :service

  def self.new_income(attrs = {})
    _object = new Income.new_income(attrs.slice(*INCOME_ATTRIBUTES))
    _object.set_defaults
    _object
  end

  def self.find(id)
    new Income.find(id)
  end

  def create
    set_movement_extra_attributes
    income.save
  end

  def create_and_approve(attrs = {})
    commit_or_rollback do
      income.approve!
      income.save
      save_ledger
    end
  end

  def update_and_approve(attrs = {})

  end

  private

    def save_ledger
      @ledger = direct_payment? ? build_ledger : NullLedger.new
      @ledger.account_id = income.id
      @ledger.operation = 'payin'

      @ledger.save_ledger
    end
end
