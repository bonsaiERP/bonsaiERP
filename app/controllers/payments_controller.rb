class PaymentsController < ApplicationController
  before_filter :set_payment, :only => [:show, :edit, :update, :destroy, :null_payment]
  # GET /payments
  # GET /payments.xml
  def index
    @payments = Payment.org.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payments }
    end
  end

  # GET /payments/1
  # GET /payments/1.xml
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.xml
  def new
    session[:payment] = {}
    #begin
    transaction = Transaction.org.find_by_type_and_id( params[:type], params[:id] )
    session[:payment][:transaction_id] = transaction.id
    @payment = transaction.new_payment
    #rescue
      #redirect_to request.referer
    #end
  end


  # POST /payments
  # POST /payments.xml
  def create
    @payment = Payment.new(params[:payment])

    if params[:payment][:transaction_id].to_i == session[:payment][:transaction_id]
      if @payment.save
        redirect_ajax @payment
      else
        render :action => "new"
      end
    else
      logger.warn "Hacking attemp! by user #{current_user.id}"
      flash[:error] = "No es posible realizar la operación"
      render :text => "Error"
    end
  end

  # DELETE /payments/:id
  def destroy
    @payment.destroy
  end

private
  def set_payment
    @payment = Payment.org.find(params[:id])
  end
end
