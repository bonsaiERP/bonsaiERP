# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensesController < ApplicationController
  include Controllers::TagSearch

  before_action :set_expense, only: [:approve, :null, :inventory]

  # GET /expenses
  def index
    @expenses = Movements::Search.new(params, Expense).search.order(date: :desc).page(@page)
  end

  # GET /expenses/1
  def show
    @expense = present Expense.find(params[:id])
  end

  # GET /expenses/new
  def new
    @es = Expenses::Form.new_expense(currency: currency)
  end

  # GET /expenses/1/edit
  def edit
    @es = Expenses::Form.find(params[:id])
  end

  # POST /expenses
  def create
    @es = Expenses::Form.new_expense(expense_params)

    if create_or_approve
      redirect_to expense_path(@es.expense), notice: 'Se ha creado un Egreso.'
    else
      @es.movement.state = 'draft' # reset status
      render 'new'
    end
  end

  # PUT /expenses/:id
  def update
    @es = Expenses::Form.find(params[:id])

    if update_or_approve
      redirect_to expense_path(@es.expense), notice: 'El Egreso fue actualizado!.'
    else
      render 'edit'
    end
  end


  # PUT /expenses/1/approve
  # Method to approve an expense
  def approve
    @expense = Expense.find(params[:id])
    @expense.approve!

    if @expense.save
      flash[:notice] = "La nota de venta fue aprobada."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    redirect_to expense_path(@expense)
  end

  # PUT /expenses/:id/approve
  # Method that nulls or enables inventory
  def inventory
    @expense.inventory = !@expense.inventory?
    @expense.extras = @expense.extras.symbolize_keys

    if @expense.save
      txt = @expense.inventory? ? 'activo' : 'desactivó'
      flash[:notice] = "Se #{txt} los inventarios."
    else
      flash[:error] = 'Exisition un error'
    end

    redirect_to expense_path(@expense.id, anchor: 'items')
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
     params.require(:expenses_quick_form).permit(*movement_params.quick_income)
    end

    def expense_params
      params.require(:expenses_form).permit(*movement_params.expense)
    end

    def movement_params
      @movement_params ||= MovementParams.new
    end

    def set_expense
      @expense = Expense.find_by_id(params[:id])
    end

    # Method to search expenses on the index
    def search_expenses
      if tag_ids
        @expenses = Expenses::Query.index_includes Expense.any_tags(*tag_ids)
      else
        @expenses = Expenses::Query.new.index(params).order('date desc, accounts.id desc')
      end

      set_expenses_filters
      @expenses = @expenses.page(@page)
    end

    def set_expenses_filters
      [:approved, :error, :due, :nulled, :inventory].each do |filter|
        @expenses = @expenses.send(filter)  if params[filter].present?
      end
    end

    def set_index_params
      params[:all] = true unless [:approved, :error, :nulled, :due, :inventory].any? {|v| params[v].present? }
    end
end
