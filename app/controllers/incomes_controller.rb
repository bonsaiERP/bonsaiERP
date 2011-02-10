# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController

  before_filter :check_currency_set, :only => [:new, :edit, :create, :update]
  before_filter :set_default_currency, :except => [:index, :destroy]


  # GET /incomes
  # GET /incomes.xml
  def index
    @incomes = Income.includes(:contact, :pay_plans).order("date DESC").paginate(:page => @page)
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    @income = Income.includes(:transaction_details, :payments, :pay_plans).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @income }
    end
  end

  # GET /incomes/new
  # GET /incomes/new.xml
  def new
    @income = Income.new(:date => Date.today, :discount => 0, :currency_exchange_rate => 1, :currency_id => @currency.id )
    @income.transaction_details.build
  end

  # GET /incomes/1/edit
  def edit
    @income = Income.find(params[:id])

    if @income.state == 'aproved'
      redirect_income
    end
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

    if @income.aproved?
      redirect_income
    else
      if @income.update_attributes(params[:income])
        redirect_to @income, :notice => 'La proforma de venta fue actualizada!.'
      else
        render :action => "edit"
      end
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.xml
  def destroy
    @income = Income.find(params[:id])
    if @income.aproved
      redirect_income
    else
      @income.destroy
      redirect_ajax @income
    end
  end
  
  # PUT /incomes/1/aprove
  # Method to aprove an income
  def aprove
    @income = Income.find(params[:id])
    if @income.aprove!
      flash[:notice] = "La nota de venta fue aprobada"
    else
      flash[:error] = "Existio un problema con la aprovación"
    end
    redirect_to @income
  end

  # Nulls an invoice
  def null
  end

private
  def set_default_currency
    @currency = Organisation.find(session[:organisation][:id]).currency
  end

  # Redirects in case that someone is trying to edit or destroy an  aproved income
  def redirect_income
    flash[:warning] = "No es posible editar una nota ya aprobada!"
    redirect_to incomes_path
  end
end
