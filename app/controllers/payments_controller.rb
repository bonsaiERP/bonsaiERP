# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentsController < ApplicationController

  # GET /payments/:id/new_income
  def new_income
    @payment = Incomes::Payment.new(account_id: params[:id], date: Time.zone.now.to_date)
    check_income
    @payment.amount = @payment.income.amount
  end

  # POST /payments/:id/income
  def income
    @payment = Incomes::Payment.new(income_params)
    check_income

    if @payment.pay
      flash[:notice] = 'El cobro se realizó correctamente.'
      render 'income.js'
    else
      render :new_income
    end
  end

  # GET /payments/:id/new_income
  def new_expense
    @payment = Expenses::Payment.new(account_id: params[:id], date: Time.zone.now.to_date)
    check_expense
    @payment.amount = @payment.expense.amount
  end

  # POST /payments/:id/expense
  def expense
    @payment = Expenses::Payment.new(expense_params)
    check_expense

    if @payment.pay
      flash[:notice] = 'El pago se realizó correctamente.'
      render 'expense.js'
    else
      render :new_expense
    end
  end

  private

    def income_params
      params.require(:incomes_payment).permit(*allowed_params)
    end

    def expense_params
      params.require(:expenses_payment).permit(*allowed_params)
    end

    def allowed_params
      [:account_id, :account_to_id, :exchange_rate, :amount, :interest, :reference, :verification, :date]
    end

    def check_income
      @payment.income.is_a?(Income)
    rescue
      render text: 'Error'
    end

    def check_expense
      @payment.expense.is_a?(Expense)
    rescue
      render text: 'Error'
    end
end
