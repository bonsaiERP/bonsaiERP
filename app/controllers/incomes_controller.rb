# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController

  #include Controllers::Transactions

  before_filter :check_authorization!
  #before_filter :check_currency_set, :only => [:new, :edit, :create, :update]
  before_filter :set_currency_rates, :only => [:index, :show]
  before_filter :set_transaction, :only => [:show, :edit, :update, :destroy, :approve]

  #before_filter :update_all_deliver

  # GET /incomes
  # GET /incomes.xml
  def index
    if params[:search].present?
      @incomes = Income.search(params)#.page(@page)
    else
      params[:option] ||= "all"
      @incomes = Income.find_with_state(params[:option])
    end
    @count = Income.org
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    respond_to do |format|
      format.html { render 'transactions/show' }
      format.json  { render :json => @transaction }
    end
  end

  # GET /incomes/new
  # GET /incomes/new.xml
  def new
    if params[:transaction_id].present?
      t = Income.org.find(params[:transaction_id])
      @transaction = t.clone_transaction
    else
      @transaction = Income.new
      @transaction.set_defaults_new
      @transaction.transaction_details.build
    end
  end

  # GET /incomes/1/edit
  def edit
    if @transaction.state == 'approved'
      flash[:warning] = "No es posible editar una nota de venta aprobada"
      redirect_to @transaction
    end
  end

  # POST /incomes
  # POST /incomes.xml
  def create
    @transaction = Income.new(params[:income])

    respond_to do |format|
      if @transaction.save_trans
        format.html { redirect_to(@transaction, :notice => 'Se ha creado una proforma de venta.') }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /incomes/1
  # PUT /incomes/1.xml
  def update
    if @transaction.approved?
      redirect_transaction
    else
      @transaction.attributes = params[:income]
      if @transaction.save_trans
        redirect_to @transaction, :notice => 'La proforma de venta fue actualizada!.'
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        render :action => "edit"
      end
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.xml
  def destroy
    if @transaction.approved?
      flash[:warning] = "No es posible anular la nota #{@transaction}."
      redirect_transaction
    else
      @transaction.null_transaction
      flash[:notice] = "Se ha anulado la nota #{@transaction}"
      redirect_to @transaction
    end
  end
  
  # PUT /incomes/1/approve
  # Method to approve an income
  def approve
    if @transaction.can_approve?(session)

      if @transaction.approve!
        flash[:notice] = "La nota de venta fue aprobada"
      else
        flash[:error] = "Existio un problema con la aprobación"
      end

      anchor = ''
      anchor = 'payments' if @transaction.cash?

      redirect_to income_path(@transaction, :anchor => anchor)
    else
      flash[:error] = "Usted no puede aprobar la venta"
      redirect_to @transaction
    end
  end

  # PUT /incomes/:id/approve_credit
  def approve_credit
    @transaction = Income.org.find(params[:id])
    @transaction.approve_credit params[:income]

    render "approve_credit"
  end


private
  #def set_default_currency
  #  @currency = Organisation.find(currency_id).currency
  #end

  # Redirects in case that someone is trying to edit or destroy an  approved income
  def redirect_income
    flash[:warning] = "No es posible editar una nota ya aprobada!"
    redirect_to incomes_path
  end

  def set_transaction
    @transaction = Income.org.find(params[:id])
  end

  def set_currency_rates
    @currency_rates = CurrencyRate.current_hash
  end
end
