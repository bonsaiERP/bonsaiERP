# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentsController < ApplicationController
  # POST /payments/:id/income
  def income
    p = IncomePayment.new(income_params)

    if p.pay
      flash[:notice] = 'El cobor se realizo correctamente'
    else
      flash[:error] = 'Exisitio un error al salvar'
    end
binding.pry
    redirect_to p.income
  end

  # POST /payments/:id/expense
  def expense
  end

private
  def income_params
    params.require(:income_payment).permit(*allowed_params)
  end

  def expense_params
    params(:expense_payment).permit(*allowed_params)
  end

  def allowed_params
    [:account_id, :account_to_id, :exchange_rate, :amount, :interest, :reference, :verification, :date]
  end
end
