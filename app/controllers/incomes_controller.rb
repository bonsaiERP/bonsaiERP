# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController

  before_filter :set_default_currency, :only => [:new, :edit]
  # GET /incomes
  # GET /incomes.xml
  def index
    @incomes = Income.paginate(:page => @page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @incomes }
    end
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    @income = Income.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @income }
    end
  end

  # GET /incomes/new
  # GET /incomes/new.xml
  def new
    @income = Income.new(:date => Date.today, :currency_id => @currency.id, :discount => 0, :currency_exchange_rate => @currency.rate )
    @income.transaction_details.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @income }
    end
  end

  # GET /incomes/1/edit
  def edit
    @income = Income.find(params[:id])
  end

  # POST /incomes
  # POST /incomes.xml
  def create
    #render :text => params.to_json
    @income = Income.new(params[:income])
    respond_to do |format|
      if @income.save
        format.html { redirect_to(@income, :notice => 'Se ha creado una proforma de venta.') }
        format.xml  { render :xml => @income, :status => :created, :location => @income }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @income.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /incomes/1
  # PUT /incomes/1.xml
  def update
    @income = Income.find(params[:id])

    respond_to do |format|
      if @income.update_attributes(params[:income])
        format.html { redirect_to(@income, :notice => 'Incomes was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @income.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.xml
  def destroy
    @income = Income.find(params[:id])
    @income.destroy

    respond_to do |format|
      format.html { redirect_to(incomes_url) }
      format.xml  { head :ok }
    end
  end

private
  def set_default_currency
    @currency = Currency.find(session[:organisation][:currency_id])
  end
end
