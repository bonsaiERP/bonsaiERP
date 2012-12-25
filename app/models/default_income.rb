# encoding: utf-8
class DefaultIncome < DefaultTransaction
  attr_reader :income

  delegate :state, to: :income, prefix: true

  def initialize(trans)
    super
    raise 'Must be a Income class' unless trans.is_a?(Income)
  end

  def income
    transaction
  end

  def create
    set_income_data

    income.save
  end

  def update
  end

private
  def set_income_data
    set_transaction_data
    income.state = 'draft' if income_state.blank?
  end
end
