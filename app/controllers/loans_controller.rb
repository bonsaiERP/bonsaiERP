# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class LoansController < TransactionsController #ApplicationController
  before_filter :check_authorization!
  #before_filter :update_all_deliver

  # GET /incomes
  # GET /incomes.xml
  def index
    @loans = Loan.get_loans
    #if params[:search].present?
    #  @incomes = Income.search(params)#.page(@page)
    #  p = params.dup
    #  p.delete(:option)
    #  @count = Income.search(p)
    #else
    #  params[:option] ||= "all"
    #  @incomes = Income.find_with_state(params[:option])
    #  @count = Income.scoped
    #end
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    @loan = Loan.find(params[:id])
  end

  # GET /incomes/new
  # GET /incomes/new.xml
  def new
    set_loan(operation: params[:operation])
  end

  # GET /incomes/1/edit
  def edit
    @loan = Loan.get_loan(params[:id])
    check_loan(@loan)
  end

  # POST /incomes
  # POST /incomes.xml
  def create
    data = params[:loanin] || params[:loanout]
    set_loan(data)
    @loan.action = "edit"

    respond_to do |format|
      if @loan.save
        format.html { redirect_to(loan_path(@loan.id), :notice => 'Se ha creado un prestamo a ser aprobado.') }
      else
        format.html { render "new" }
      end
    end
  end

  # PUT /incomes/1
  # PUT /incomes/1.xml
  def update
    @loan = Loan.get_loan(params[:id])
    check_loan(@loan)
    data = params[:loanin] || params[:loanout]
    @loan.action = "edit"

    if @loan.update_attributes(data)
      redirect_to loan_path(@loan.id)
    else
      render "edit"
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.xml
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
    if @loan.approve!
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
  def set_loan(data)
    data[:currency_id] = OrganisationSession.currency_id if data[:currency_id].blank?

    case
    when data[:operation] == "in"
      @loan = Loanin.new(data)
      @loan.action = "edit"
    when data[:operation] == "out"
      @loan = Loanout.new(data)
      @loan.action = "edit"
    else
      flash[:error] = "Faltan parametros"
      return redirect_to loans_path
    end
  end

  def check_loan(loan)
    unless loan.respond_to?(:is_loan?)
      flash[:error] = "Ha seleccionado un registro incorrecto"
      redirect_to loans_path
      return
    end

    unless loan.draft?
      flash[:warning] = "El registro no se puede editar"
      return redirect_to loan_path(loan.id)
    end
  end
end

