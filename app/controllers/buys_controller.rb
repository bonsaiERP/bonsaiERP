# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BuysController < ApplicationController
  before_filter :check_authorization!
  before_filter :set_currency_rates, :only => [:index, :show]
  before_filter :set_transaction, :only => [:show, :edit, :update, :destroy, :approve]

  #respond_to :html, :xml, :json
  # GET /buys
  # GET /buys.xml
  def index
    if params[:search].present?
      @buys = Buy.search(params)
      p = params.dup
      p.delete(:option)
      @count = Buy.search(p)
    else
      params[:option] ||= "all"
      @buys = Buy.find_with_state(params[:option])
      @count = Buy.org
    end
  end
0
  # GET /buys/1
  # GET /buys/1.xml
  def show
    respond_to do |format|
      format.html { render 'transactions/show' }
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /buys/new
  # GET /buys/new.xml
  def new
    if params[:transaction_id].present?
      t = Buy.org.find(params[:transaction_id])
      @transaction = t.clone_transaction
    else
      @transaction = Buy.new
      @transaction.set_defaults_new
      @transaction.transaction_details.build
    end
  end

  # GET /buys/1/edit
  def edit
    #if @transaction.state == 'approved'
    #  flash[:warning] = "No es posible editar una nota de compra aprobada"
    #  redirect_to @transaction
    #end
  end


  # POST /buys
  # POST /buys.xml
  def create
    @transaction = Buy.new(params[:buy])
    respond_to do |format|
      if @transaction.save_trans
        format.html { redirect_to(@transaction, :notice => 'Se ha creado una proforma de compra.') }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        format.html { render :action =>  "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /buys/1
  # PUT /buys/1.xml
  def update
    if @transaction.approved?
      redirect_transaction
    else
      if @transaction.update_attributes(params[:buy])
        redirect_to @transaction, :notice => 'La proforma de compra fue actualizada!.'
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        render :action => "edit"
      end
    end
  end

  # DELETE /buys/1
  # DELETE /buys/1.xml
  def destroy
    if @transaction.approved?
      redirect_transaction
    else
      @transaction.null_transaction
      redirect_to @transaction, :notice => "Se ha anulado #{@transaction}"
    end
  end

  # PUT /buys/1/approve
  # Method to approve an income
  def approve
    if @transaction.approve!
      flash[:notice] = "La compra fue aprobada"
    else
      flash[:error] = "Existio un problema con la aprobación"
    end

    anchor = ''
    anchor = 'payments' if @transaction.cash?

    redirect_to buy_path(@transaction, :anchor => anchor)
  end

  private

  def set_currency_rates
    @currency_rates = CurrencyRate.current_hash
  end

  def set_transaction
    @transaction = Buy.org.find(params[:id])
  end
end
