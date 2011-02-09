class PaymentsController < ApplicationController
  # GET /payments
  # GET /payments.xml
  def index
    @payments = Payment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payments }
    end
  end

  # GET /payments/1
  # GET /payments/1.xml
  def show
    @payment = Payment.find(params[:id])

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
    transaction = Transaction.find_by_type_and_id( params[:type], params[:id] )
    session[:payment][:transaction_id] = transaction.id
    @payment = transaction.new_payment
    #rescue
      #redirect_to request.referer
    #end
  end

  # GET /payments/1/edit
  def edit
    @payment = Payment.find(params[:id])
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
      render :text => "Hacking attemp!"
      #TODO Log error and recognize a Hacking attack
    end
  end

  # PUT /payments/1
  # PUT /payments/1.xml
  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to(@payment, :notice => 'Payment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.xml
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to(payments_url) }
      format.xml  { head :ok }
    end
  end
end
