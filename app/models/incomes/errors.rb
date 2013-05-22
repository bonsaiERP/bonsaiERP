# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::Errors < Struct.new(:income)
  attr_reader :errors
  delegate :balance, :total, :income_details, to: :income

  def set_errors
    income.has_error = false
    @errors = {}
    balance_errors
    income_details_errors

    income.error_messages = errors
  end

private
  def balance_errors
    if balance < 0
      income.has_error = true
      errors[:balance] = ['movement.negative_balance']
    end
  end

  def income_details_errors
    if (tot = income_details.select {|det| det.balance < 0 }.count) > 0
      income.has_error = true
      msg = 'movement.' << (tot > 1 ? 'negative_items_balance' : 'negative_item_balance')
      errors[:income_details] = [msg]
    end
  end
end
