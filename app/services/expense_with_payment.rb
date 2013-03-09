# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpenseWithPayment < BaseService# < DefaultExpense
  attribute :ref_number, String
  attribute :date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :exchange_rate, Decimal
  attribute :project_id, Integer
  attribute :bill_number, String
  attribute :description, String

  attr_accessor :expense

  delegate :contact, :project, :is_approved?, :expense_details, to: :expense

  def initialize(args = {})
    super
    @expense = Expense.new(args)
  end

end
