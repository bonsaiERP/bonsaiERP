# encoding: utf-8
class DefaultIncome < DefaultTransaction
  attr_reader :income

  delegate :state, to: :income

  def initialize(trans)
    super
    raise 'Must be a Income class' unless trans.is_a?(Income)
  end

  def income
    transaction
  end

  def create(params)
    res = true
    set_income_data

    ActiveRecord::Base.transaction do
    end

    res
  end

  def update
  end

private
  def set_income_data
    income.state = 'draft' if income_state.blank?
  end
end
