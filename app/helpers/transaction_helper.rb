# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module TransactionHelper
  def search_path(trans, options = {})
    options[:format] ||= 'json'

    case 
    when trans.class.to_s =~ /Income/
      search_income_items_path(options)
    when trans.class.to_s =~ /Expense/
      search_expense_items_path(options)
    end
  end
end
