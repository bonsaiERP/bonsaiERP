# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module MovementHelper
  def search_path(trans, options = {})
    options[:format] ||= 'json'

    case
    when trans.class.to_s =~ /Income/
      search_income_items_path(options)
    when trans.class.to_s =~ /Expense/
      search_expense_items_path(options)
    end
  end

  def state_search_options(sel = nil)
    options_for_select(t('movement.states').map { |key, val| [val, key] }, sel)
  end

  def get_expense_url(exp_serv)
    if exp_serv.expense_id
      expense_path(exp_serv.expense_id)
    else
      expenses_path
    end
  end

  def expense_form_method(exp_serv)
    if exp_serv.expense_id
      'put'
    else
      'post'
    end
  end

  def get_income_url(inc_serv)
    if inc_serv.income_id
      income_path(inc_serv.income_id)
    else
      incomes_path
    end
  end

  def income_form_method(inc_serv)
    if inc_serv.income_id
      'put'
    else
      'post'
    end
  end

  def form_model_name(movement)
    movement.to_s.underscore.gsub('/', '_')
  end
end
