# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController

  # GET /incomes
  def index
    @incomes = IncomeQuery.new.search(
      search: params[:search]
    ).page(@page)
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    @income = present Income.find(params[:id])
  end

  # GET /incomes/new
  def new
    @income = Income.new_income(ref_number: Income.get_ref_number, date: Date.today, currency: currency)
    @income.income_details.build(quantity: 1.0)
  end

  # GET /incomes/1/edit
  def edit
    @income = Income.find(params[:id])
  end

  # POST /incomes
  def create
    di = DefaultIncome.new(Income.new_income(income_params))

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
    @income = Income.find(params[:id])
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
    redirect_to(@income, alert: 'El Ingreso ya esta aprovado') and return unless @income.is_draft?

    @income.approve!
    if @income.save
      flash[:notice] = "El Ingreso fue aprobado."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    redirect_to income_path(@income)
  end

  def history
    @history = TransactionHistory.find(params[:id])
    @trans = @history.transaction
    @transaction = @history.get_transaction("Income")

    render "transactions/history"
  end

private
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
