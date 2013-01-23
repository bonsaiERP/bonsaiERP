class TestVirtue < BaseService
  attr_reader :income

  delegate :ref_number, :date, :contact, :currency, :exchange_rate, :project,
    :bill_number, :description, :income_details, :income_details_attributes,:errors, to: :income

  def initialize(inc)
    @income = inc
  end

  def self
    income
  end
end
