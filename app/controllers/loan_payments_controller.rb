class LoanPaymentsController < ApplicationController
  before_filter :check_loan!


  #####################################
  # Loans::Receive

  # GET /loans_paymens/:id/new_pay
  def new_pay
    @payment = Loans::ReceivePaymentForm.new(account_id: params[:id], date: today)
  end

  # POST /loan_payments/:id/pay
  def pay
    @payment = Loans::ReceivePaymentForm.new(pay_params)

    if @payment.create_payment
      flash[:notice] = 'Se relizo el pago correctamente.'
      @path = loan_path(@payment.loan.id)
      render 'js/redirect'
    else
      render :new_pay
    end
  end

  # GET /loan_payments/:id/new_pay_interest
  def new_pay_interest
    @payment = Loans::ReceivePaymentForm.new(account_id: params[:id], date: today)
  end

  # POST /loan_payments/:id/pay_interest
  def pay_interest
    @payment = Loans::ReceivePaymentForm.new(pay_params)

    if @payment.create_interest
      flash[:notice] = 'Se pago los intereses correctamente.'
      @path = loan_path(@payment.loan.id)
      render 'js/redirect'
    else
      render :new_pay_interest
    end
  end

  #####################################
  # Loans::Give

  # GET /loan_payments/:id/new_charge
  def new_charge
    @payment = Loans::GivePaymentForm.new(account_id: params[:id], date: today)
  end

  # POST /loan_payments/:id/new_charge
  def charge
    @payment = Loans::GivePaymentForm.new(charge_params)

    if @payment.create_payment
      flash[:notice] = 'Se relizo el cobro correctamente.'
      @path = loan_path(@payment.loan.id)
      render 'js/redirect'
    else
      render :new_charge
    end
  end

  # GET /loan_payments/:id/new_charge_interest
  def new_charge_interest
    @payment = Loans::GivePaymentForm.new(account_id: params[:id], date: today)
  end

  # POST /loan_payments/:id/charge_interest
  def charge_interest
    @payment = Loans::GivePaymentForm.new(charge_params)

    if @payment.create_interest
      flash[:notice] = 'Se relizo el cobro de intereses correctamente.'
      @path = loan_path(@payment.loan.id)
      render 'js/redirect'
    else
      render :new_charge_interest
    end
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

    def common_params
      [:account_to_id, :amount, :exchange_rate,
        :date, :reference, :verification]
    end

    def pay_params
      params.require(:loans_receive_payment_form)
      .permit(*common_params).merge(account_id: params[:id])
    end

    def charge_params
      params.require(:loans_give_payment_form)
      .permit(*common_params).merge(account_id: params[:id])
    end

    def today
      Time.zone.now.to_date
    end
end
