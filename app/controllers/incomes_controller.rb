# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController

  # GET /incomes
  def index
    @incomes = Income.page(@page)
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    @income = Income.find(params[:id])

    respond_to do |format|
      format.html
      format.json  { render :json => @income }
    end
  end

  # GET /incomes/new
  def new
    @income = Income.new(ref_number: Income.get_ref_number, date: Date.today, currency: currency)
    @income.transaction_details.build(quantity: 1.0)
  end

  # GET /incomes/1/edit
  def edit
    @income = Income.find(params[:id])
  end

  # POST /incomes
  def create
    di = DefaultIncome.new(Income.new(income_params))

    if di.create
      redirect_to di.income, notice: 'Se ha creado una proforma de venta.'
    else
      @income = di.income
      render 'new'
    end
  end

  # POST /incomes/quick_income
  def quick_income
    @quick_income = QuickIncome.new(quick_income_params)

    if @quick_income.create
      flash[:notice] = "El ingreso fue creado."
    else
      flash[:error] = "Existio errores al crear el ingreso."
    end

    redirect_to incomes_path
  end

  # PUT /incomes/1
  def update
    di = DefaultIncome.new(Income.find(params[:id]))

    if di.update(income_params)
      redirect_to di.income, notice: 'La proforma de venta fue actualizada!.'
    else
      @income = di.income
      render 'edit'
    end
  end

  # DELETE /incomes/1
  def destroy
    if @transaction.approved?
      flash[:warning] = "No es posible anular la nota #{@transaction}."
      redirect_transaction
    else
      @transaction.null_transaction
      flash[:notice] = "Se ha anulado la nota #{@transaction}."
      redirect_to @transaction
    end
  end

  # PUT /incomes/1/approve
  # Method to approve an income
  def approve
    if @transaction.approve!
      flash[:notice] = "La nota de venta fue aprobada."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    anchor = ''
    anchor = 'payments' if @transaction.cash?

    redirect_to income_path(@transaction, :anchor => anchor)
  end

  def history
    @history = TransactionHistory.find(params[:id])
    @trans = @history.transaction
    @transaction = @history.get_transaction("Income")

    render "transactions/history"
  end

private

  # Redirects in case that someone is trying to edit or destroy an  approved income
  def redirect_income
    flash[:warning] = "No es posible editar una nota ya aprobada!."
    redirect_to incomes_path
  end

  def set_transaction
    @transaction = Income.find(params[:id])
    check_edit if ["edit", "update"].include?(params[:action])
  end

  # Checks for transactions to edit
  def check_edit
    unless allow_transaction_action?(@transaction)
      flash[:warning] = "No es posible editar la nota de venta."
      return redirect_to @transaction
    end
  end

  def quick_income_params
   params.require(:quick_income).permit(*transaction_params.quick_income)
  end

  def income_params
    params.require(:income).permit(*transaction_params.income)
  end

  def transaction_params
    @transaction_params ||= TransactionParams.new
  end
end
