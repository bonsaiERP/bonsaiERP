# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module TransactionHelper
  def search_path(trans, options = {})
    options[:format] ||= 'json'

    case trans.class.to_s
    when 'Income', 'IncomePresenter', 'DirectIncome'
      search_income_items_path(options)
    when 'Expense', 'ExpensePresenter'
      search_expense_items_path(options)
    end
  end
end
