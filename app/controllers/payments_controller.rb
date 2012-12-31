# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PaymentsController < ApplicationController
  # GET /payments/new
  def new
    @transaction = Transaction.find( params[:id] )
    @account_ledger = @transaction.new_payment
    @payment = PaymentPresenter.new(@transaction)
  end


  # POST /payments
  def create
    case params[:klass]
    when "PaymentIncome"
      @payment = PaymentIncome.new(income_params)
      path = "/incomes/#{@payment.transaction_id}"
    when "PaymentExpense"
      @payment = PaymentExpense.new(expense_params)
      path = "/expenses/#{@payment.transaction_id}"
    else
      flash[:error] = "Existe errores en el cobro"
      redirect_to incomes_path and return
    end

    if @payment.pay
      flash[:notice] = 'Cobro salvado correctamente'
    end

    redirect_to path
  end

private
  def income_params
    params.require(:payment_income).permit(*allowed_params)
  end

  def allowed_params
    [:transaction_id, :account_id, :exchange_rate, :amount, :interest, :reference, :verification, :date]
  end
end
