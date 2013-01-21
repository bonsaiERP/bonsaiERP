# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentsController < ApplicationController
  before_filter :check_income_or_expense

  # POST /payments/:id/income
  def income
    p = IncomePayment.new(income_params)

    if p.pay
      flash[:notice] = 'El cobro se realizo correctamente.'
    else
      flash[:error] = 'Exisitio un error al salvar el cobro.'
    end

    redirect_to income_path(p.income, anchor: 'payments')
  end

  # POST /payments/:id/expense
  def expense
    p = ExpensePayment.new(expense_params)

    if p.pay
      flash[:notice] = 'El pago se realizo correctamente.'
    else
      flash[:error] = 'Exisitio un error al salvar el pago.'
    end

    redirect_to expense_path(p.expense, anchor: 'payments')
  end

private
  def income_params
    params.require(:income_payment).permit(*allowed_params)
  end

  def expense_params
    params.require(:expense_payment).permit(*allowed_params)
  end

  def allowed_params
    [:account_id, :account_to_id, :exchange_rate, :amount, :interest, :reference, :verification, :date]
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
      redirect_to dashboard_path and return
    end
  end

  def check_expense
    unless Expense.exists? params[:id]
      flash[:error] = 'No se puede realizar el pago, el egreso no existe.'
      redirect_to dashboard_path and return
    end
  end
end
