# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensesController < ApplicationController
  before_filter :set_expense, only: [:approve, :null]

  # GET /expenses
  def index
    search_expenses
  end

  # GET /expenses/1
  def show
    @expense = present Expense.find(params[:id])
  end

  # GET /expenses/new
  def new
    @es = Expenses::Form.new_expense(date: Date.today)
  end

  # GET /expenses/1/edit
  def edit
    @es = Expenses::Form.find(params[:id])
  end

  # POST /expenses
  def create
    @es = Expenses::Form.new_expense(expense_params)

    if create_or_approve
      redirect_to @es.expense, notice: 'Se ha creado un Egreso.'
    else
      render 'new'
    end
  end

  # PUT /expenses/:id
  def update
    @es = Expenses::Form.find(params[:id])

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
    if @expense.approved?
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
    @expense = Expense.find(params[:id])
    if @expense.approve!
      flash[:notice] = "La nota de venta fue aprobada."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    redirect_to expense_path(@expense)
  end

  def history
    @history = TransactionHistory.find(params[:id])
    @trans = @history.transaction
    @transaction = @history.get_transaction("Expense")

    render "transactions/history"
  end

  # PUT /incomes/:id/null
  def null
    if @expense.null!
      redirect_to expense_path(@expense), notice: 'Se anulo correctamente el egreso.'
    else
      redirect_to expense_path(@expense), error: 'Existio un error al anular el egreso.'
    end
  end

private
  # Creates or approves a Expenses::Form instance
  def create_or_approve
    if params[:commit_approve]
      @es.create_and_approve 
    else
      @es.create
    end
  end

  def update_or_approve
    if params[:commit_approve]
      @es.update_and_approve(expense_params)
    else
      @es.update(expense_params)
    end
  end

  def quick_expense_params
   params.require(:quick_expense).permit(*transaction_params.quick_income)
  end

  def expense_params
    params.require(:expenses_form).permit(*transaction_params.expense)
  end

  def transaction_params
    @transaction_params ||= TransactionParams.new
  end

  def set_expense
    @expense = Expense.find_by_id(params[:id])
  end

  # Method to search expenses on the index
  def search_expenses
    @expenses = case
                when params[:contact_id].present?
                  Expense.contact(params[:contact_id]).order('date desc').page(@page)
                when params[:search].present?
                  Expense.like(params[:search]).page(@page)
                else
                  Expense.order('date desc').page(@page)
                end
    @expenses = @expenses.includes(:contact, transaction: [:creator, :approver, :nuller]).order('date desc, id desc')
  end
end
