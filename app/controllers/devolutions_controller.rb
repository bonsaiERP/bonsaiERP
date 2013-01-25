# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DevolutionsController < ApplicationController
  before_filter :check_income_or_expense

  # POST /devolutions/:id/income
  def income
    p = IncomeDevolution.new(income_params)

    if p.pay_back
      flash[:notice] = 'La devolución realizo correctamente.'
    else
      flash[:error] = 'Exisitio un error al salvar la devolucion.'
    end

    redirect_to income_path(p.income, anchor: 'payments')
  end

  # POST /devolutions/:id/expense
  def expense
    p = ExpenseDevolution.new(expense_params)

    if p.pay_back
      flash[:notice] = 'la devolucion se realizo correctamente.'
    else
      flash[:error] = 'Exisitio un error al salvar el la devolucion.'
    end

    redirect_to expense_path(p.expense, anchor: 'payments')
  end

private
  def income_params
    params.require(:income_devolution).permit(*allowed_params)
  end

  def expense_params
    params.require(:expense_devolution).permit(*allowed_params)
  end

  def allowed_params
    [:account_id, :account_to_id, :exchange_rate, :amount, :reference, :verification, :date]
  end

  def check_income_or_expense
    if params.fetch(:action) == 'income'
      check_income
    else
      check_expense
    end
  end

  def check_income
    unless Income.exists? params[:id]
      flash[:error] = 'No se puede realizar el cobro, el ingreso no existe.'
      redirect_to :back and return
    end
  end

  def check_expense
    unless Expense.exists? params[:id]
      flash[:error] = 'No se puede realizar el pago, el egreso no existe.'
      redirect_to :back and return
    end
  end
end

