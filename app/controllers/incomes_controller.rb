# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < ApplicationController
  include Controllers::TagSearch
  include Controllers::Print

  #respond_to :html, :js, :pdf
  before_action :set_income, only: [:approve, :null, :inventory, :destroy]

  # GET /incomes
  def index
    @incomes = Movements::Search.new(params, Income).search.order(date: :desc).page(@page)
  end

  # GET /incomes/1
  def show
    @income = present Income.find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show.print', "Ingreso-#{@income}" }
    end
  end

  # GET /incomes/new
  def new
    #@is = params[:id].present? ? Incomes::Clone.new(params[:id]).clone : Incomes::Form.new_income(currency: currency)
    @is = Incomes::Form.new_income(currency: currency)
  end

  # GET /incomes/1/edit
  def edit
    @is = Incomes::Form.find(params[:id])
  end

  # POST /incomes
  def create
    @is = Incomes::Form.new_income(income_params)

    if create_or_approve
      redirect_to income_path(@is.income), notice: 'Se ha creado un Ingreso.'
    else
      @is.movement.state = 'draft' # reset status
      render :new
    end
  end

  # PATCH /incomes/:id
  def update
    @is = Incomes::Form.find(params[:id])

    if update_or_approve
      redirect_to income_path(@is.income), notice: 'El Ingreso fue actualizado!.'
    else
      render :edit
    end
  end

  # PATCH /incomes/:id/approve
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

  # PATCH /incomes/:id/approve
  # Method that nulls or enables inventory
  def inventory
    @income.inventory = !@income.inventory?

    if @income.save
      txt = @income.inventory? ? 'activo' : 'desactivó'
      flash[:notice] = "Se #{txt} los inventarios."
    else
      flash[:error] = "Exisition un error modificando el estado de inventarios."
    end

    redirect_to income_path(@income.id, anchor: 'items')
  end

  # PATCH /incomes/:id/null
  def null
    if @income.null!
      redirect_to income_path(@income), notice: 'Se anulo correctamente el ingreso.'
    else
      redirect_to income_path(@income), error: 'Existio un error al anular el ingreso.'
    end
  end

  private

    # Creates or approves a ExpenseService instance
    def create_or_approve
      if params[:commit_approve]
        @is.create_and_approve
      else
        @is.create
      end
    end

    def update_or_approve
      if params[:commit_approve]
        @is.update_and_approve(income_params)
      else
        @is.update(income_params)
      end
    end

    def income_params
      params.require(:incomes_form).permit(*movement_params.income)
    end

    def movement_params
      @movement_params ||= MovementParams.new
    end

    def set_income
      @income = Income.find_by_id(params[:id])
    end

    # Method to search incomes on the index
    def search_incomes
      if tag_ids
        @incomes = Incomes::Query.index_includes Income.any_tags(*tag_ids)
      else
        @incomes = Incomes::Query.new.index(params).order('date desc, accounts.id desc')
      end

      set_incomes_filters
      @incomes = @incomes.page(@page)
    end

    def set_incomes_filters
      [:approved, :error, :due, :nulled, :inventory].each do |filter|
        @incomes = @incomes.send(filter)  if params[filter].present?
      end
    end

    def set_index_params
      params[:all] = true unless [:approved, :error, :nulled, :due, :inventory].any? { |key| params[key].present? }
    end
end
