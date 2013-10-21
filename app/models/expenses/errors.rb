# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expenses::Errors < Struct.new(:expense)
  attr_reader :errors
  delegate :balance, :total, :expense_details, to: :expense

  def set_errors
    expense.has_error = false
    @errors = {}
    balance_errors
    expense_details_errors

    expense.error_messages = errors
  end

  private

    def balance_errors
      if balance < 0
        expense.has_error = true
        errors[:balance] = ['movement.negative_balance']
      end
    end

    def expense_details_errors
      if (tot = expense_details.select {|det| det.balance < 0 }.count) > 0
        expense.has_error = true
        msg = 'movement.' << (tot > 1 ? 'negative_items_balance' : 'negative_item_balance')
        errors[:expense_details] = [msg]
      end
    end
end
