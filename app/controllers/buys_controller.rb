# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BuysController < ApplicationController

  before_filter :set_currency_rates, :only => [:index, :show]
  before_filter :set_transaction, :only => [:show, :edit, :update, :destroy, :approve]

  #respond_to :html, :xml, :json
  # GET /buys
  # GET /buys.xml
  def index
    @buys = Buy.find_with_state(params[:option]).page(@page)
  end

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
    @transaction = Buy.new(:date => Date.today, :discount => 0, :currency_exchange_rate => 1, :currency_id => currency_id )
    @transaction.transaction_details.build
  end

  # GET /buys/1/edit
  def edit
    @transaction = Buy.find(params[:id])
  end

  # POST /buys
  # POST /buys.xml
  def create
    @transaction = Buy.new(params[:buy])
    @transaction.save
  end

  # PUT /buys/1
  # PUT /buys/1.xml
  def update
    @transaction.update_attributes(params[:buy])
  end

  # DELETE /buys/1
  # DELETE /buys/1.xml
  def destroy
    @transaction.destroy
  end

  # PUT /buys/1/approve
  # Method to approve an income
  def approve
    if @transaction.approve!
      flash[:notice] = "La compra fue aprobada"
    else
      flash[:error] = "Existio un problema con la aprovación"
    end

    anchor = ''
    anchor = 'payments' if @transaction.cash?

    redirect_to buy_path(@transaction, :anchor => anchor)
  end
private
  def set_currency_rates
    @currency_rates = {}
    CurrencyRate.active.each {|cr| @currency_rates[cr.currency_id] = cr.rate }
  end

  def set_transaction
    @transaction = Buy.org.find(params[:id])
  end
end
