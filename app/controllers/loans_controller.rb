# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class LoansController < TransactionsController #ApplicationController
  before_filter :check_authorization!
  #before_filter :update_all_deliver

  # GET /incomes
  # GET /incomes.xml
  def index
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
    @loan = set_loan(operation: params[:operation])
    @loan.action = "edit"
  end

  # GET /incomes/1/edit
  def edit
  end

  # POST /incomes
  # POST /incomes.xml
  def create
    data = params[:loanin] || params[:loanout]
    @loan = set_loan(data)
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
    @transaction.attributes = params[:income]
    if @transaction.save_trans
      redirect_to @transaction, :notice => 'La proforma de venta fue actualizada!.'
    else
      @transaction.transaction_details.build unless @transaction.transaction_details.any?
      render get_template(@transaction)
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
  def set_loan(data)
    data[:currency_id] = OrganisationSession.currency_id if data[:currency_id].blank?

    case
    when data[:operation] == "in"
      @loan = Loanin.new(data)
    when data[:operation] == "out"
      @loan = Loanout.new(data)
    else
      flash[:error] = "Faltan parametros"
      redirect_to loans_path
    end
  end
end

