# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensesController < ApplicationController

  # GET /expenses
  def index
    @expenses = ExpenseQuery.new.search(
      search: params[:search]
    ).order('date desc').page(@page)
  end

  # GET /expenses/1
  def show
    @expense = present ExpenseQuery.new(Expense.where(id: params[:id])).inc.first
  end

  # GET /expenses/new
  def new
    @es = ExpenseService.new_expense
  end

  # GET /expenses/1/edit
  def edit
    @es = ExpenseService.find(params[:id])
  end

  # POST /expenses
  def create
    @es = ExpenseService.new_expense(expense_params)

    if create_or_approve
      redirect_to @es.expense, notice: 'Se ha creado un Egreso.'
    else
      render 'new'
    end
  end

  # PUT /expenses/:id
  def update
    @es = ExpenseService.find(params[:id])

    if update_or_approve
      redirect_to @es.expense, notice: 'El Egreso fue actualizado!.'
    else
      render 'edit'
    end
  end

  # POST /expenses/quick_expense
  def quick_expense
    @quick_expense = QuickExpense.new(quick_expense_params)

    if @quick_expense.create
      flash[:notice] = "El egreso fue creado."
    else
      flash[:error] = "Existio errores al crear el egreso."
    end

    redirect_to expenses_path
  end

  # DELETE /expenses/1
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
  
  # PUT /expenses/1/approve
  # Method to approve an expense
  def approve
    if @transaction.approve!
      flash[:notice] = "La nota de venta fue aprobada."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    anchor = ''
    anchor = 'payments' if @transaction.cash?

    redirect_to expense_path(@transaction, :anchor => anchor)
  end

  def history
    @history = TransactionHistory.find(params[:id])
    @trans = @history.transaction
    @transaction = @history.get_transaction("Expense")

    render "transactions/history"
  end

private
  # Creates or approves a ExpenseService instance
  def create_or_approve
    if params[:commit_approve]
      @es.create_and_approve 
    else
      @es.create
    end
  end

  def update_or_approve
    if params[:commit_approve]
      @es.update_and_approve 
    else
      @es.update
    end
  end

  def quick_expense_params
   params.require(:quick_expense).permit(*transaction_params.quick_income)
  end

  def expense_params
    params.require(:expense_service).permit(*transaction_params.expense)
  end

  def transaction_params
    @transaction_params ||= TransactionParams.new
  end
end
