class LoanPaymentsController < ApplicationController
  before_filter :check_loan!


  #####################################
  # Loans::Receive

  # GET /loans_paymens/:id/new_pay
  def new_pay
    @payment = Loans::PaymentReceive.new(account_id: params[:id], date: Date.today)
  end

  # POST /loan_payments/:id/pay
  def pay
    @payment = Loans::PaymentReceive.new(receive_payment_params)

    if @payment.create_payment
      flash[:notice] = 'Se relizo el pago correctamente.'
      @path = loan_path(@payment.loan.id)
      render 'js/redirect'
    else
      render :new_receive
    end
  end

  # GET /loan_payments/:id/new_interest_pay
  def new_interest_pay
    @payment = Loans::PaymentReceive.new(account_id: params[:id], date: Date.today)
  end

  # POST /loan_payments/:id/interest_receive
  def interest_pay
    @payment = Loans::PaymentReceive.new(account_id: params[:id], date: Date.today)

    if @payment.create_payment
      flash[:notice] = 'Se pago los intereses correctamente.'
      @path = loan_path(@payment.loan.id)
      render 'js/redirect'
    else
      render :new_interest_receive
    end
  end

  #####################################
  # Loans::Give

  # GET /loan_payments/:id/new_charge
  def new_charge

  end

  # POST /loan_payments/:id/new_charge
  def charge

  end

  # GET /loan_payments/:id/new_charge_interest
  def new_charge_interest

  end

  # POST /loan_payments/:id/charge_interest
  def charge_interest

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
