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
    @expense = Expense.new_expense(ref_number: Expense.get_ref_number, date: Date.today, currency: currency)
    @expense.expense_details.build(quantity: 1.0)
  end

  # GET /expenses/1/edit
  def edit
    @expense = Expense.find(params[:id])
  end

  # POST /expenses
  def create
    de = DefaultExpense.new(Expense.new_expense(expense_params))
    method = params[:commit_approve].present? ? :create_and_approve : :create

    if de.send(method)
      redirect_to de.expense, notice: 'Se ha creado un Egreso.'
    else
      @expense = de.expense
      render 'new'
    end
  end

  # POST /expenses/quick_expense
  def quick_expense
    @quick_expense = QuickExpense.new(quick_expense_params)

    if @quick_expense.create
      flash[:notice] = "El ingreso fue creado."
    else
      flash[:error] = "Existio errores al crear el ingreso."
    end

    redirect_to expenses_path
  end

  # PUT /incomes/:id
  def update
    @expense = Expense.find(params[:id])
    de = DefaultExpense.new(Expense.find(params[:id]))

    if de.update(expense_params)
      redirect_to de.expense, notice: 'El egreso fue actualizado!.'
    else
      @income = de.expense
      render 'edit'
    end
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
  def quick_expense_params
   params.require(:quick_expense).permit(*transaction_params.quick_income)
  end

  def expense_params
    params.require(:expense).permit(*transaction_params.expense)
  end

  def transaction_params
    @transaction_params ||= TransactionParams.new
  end
end
