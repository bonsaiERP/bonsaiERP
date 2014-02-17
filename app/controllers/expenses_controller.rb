# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensesController < ApplicationController
  include Controllers::TagSearch

  before_filter :set_expense, only: [:approve, :null, :inventory]

  # GET /expenses
  def index
    set_index_params
    search_expenses
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
      @expenses = case
                  when params[:contact_id].present?
                    Expense.contact(params[:contact_id]).order('date desc')
                  when params[:search].present?
                    Expenses::Query.new.search(params[:search])
                  else
                    Expense.order('date desc')
                  end

      @expenses = @expenses.all_tags(*tag_ids)  if params[:search] && has_tags?

      @expenses = @expenses.includes(:contact, :tax, :updater, :creator, :approver, :nuller).order('date desc, accounts.id desc').page(@page)
      set_expenses_filters
    end

    def set_expenses_filters
      case
      when params[:approved].present?
        @expenses = @expenses.approved
      when params[:error].present?
        @expenses = @expenses.error
      when params[:due].present?
        @expenses = @expenses.due
      when params[:nulled].present?
        @expenses = @expenses.nulled
      when params[:inventory].present?
        @expenses = @expenses.inventory
      end
    end

    def set_index_params
      params[:all] = true unless [:approved, :error, :nulled, :due, :inventory].any? {|v| params[v].present? }
    end
end
