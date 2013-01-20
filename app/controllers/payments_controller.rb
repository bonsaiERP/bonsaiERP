# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentsController < ApplicationController
  # POST /payments/:id/income
  def income
    p = PaymentIncome.new(income_params)

    if p.pay
      flash[:notice] = 'El cobor se realizo correctamente'
    else
    end

    redirect_to income
  end

  # POST /payments/:id/expense
  def expense
  end

private
  def income_params
    params.require(:payment_income).permit(*allowed_params)
  end

  def expense_params
    params(:payment_expense).permit(*allowed_params)
  end

  def allowed_params
    [:transaction_id, :account_id, :exchange_rate, :amount, :interest, :reference, :verification, :date]
  end
end
