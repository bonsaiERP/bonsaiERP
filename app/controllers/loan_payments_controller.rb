class LoanPaymentsController < ApplicationController
  before_filter :check_loan!

  # GET loans_paymens/:id/new
  def new_receive
    @payment = Loans::PaymentReceive.new(account_id: params[:id])
  end

  # POST loan_payments/:id
  def receive

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

    def payment_params

    end
end
