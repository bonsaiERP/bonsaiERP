class LoanPaymentsController < ApplicationController
  before_filter :check_loan!

  # GET loans_paymens/:id/new_receive
  def new_receive
    @payment = Loans::PaymentReceive.new(account_id: params[:id], date: Date.today)
  end

  # POST loan_payments/:id
  def receive
    @payment = Loans::PaymentReceive.new(receive_payment_params)

    if @payment.create_payment
    else
      render :new_receive
    end
  end

  # GET loan_payments/:id/new_interest
  def new_interest_receive
    @payment = Loans::PaymentReceive.new(account_id: params[:id], date: Date.today)
  end

  # POST loan_payments/:id/interest_receive
  def interest_receive
    @payment = Loans::PaymentReceive.new(account_id: params[:id], date: Date.today)
  end

  private

    def check_loan!
      @loan = Account.find_by(id: params[:id])

      unless @loan.is_a?(Loan)
        if request.xhr?
          render text: 'Error'
        else
          flash[:warning] = 'Ha ingresado un Prestamo invalido.'
          redirect_to dashboar_path and return
        end
      end
    end

    def receive_payment_params
      params.require(:loans_payment_receive).permit(
        :account_to_id, :amount, :exchange_rate,
        :date, :reference
      ).merge(account_id: params[:id])
    end
end
