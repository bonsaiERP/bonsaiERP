# encoding: utf-8
class DirectIncome < DefaultTransaction
  attribute :ref_number, String
  attribute :date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :exchange_rate, Decimal
  attribute :project_id, Integer
  attribute :bill_number, String
  attribute :due_date, Date
  attribute :description, String
  attribute :direct, Boolean
  attribute :account_to_id, Integer

  attr_accessor :income

  delegate :contact, :is_approved?, :income_details, 
    :income_details_attributes, :income_details_attributes=,
    :subtotal, :total, to: :income

  def initialize(attributes = {})
    super attributes.merge(ref_number: Income.get_ref_number, date: Date.today, currency: OrganisationSession.currency)
    @income = Income.new_income{|inc| inc.income_details.build }
  end
end
