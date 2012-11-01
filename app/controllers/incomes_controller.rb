# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesController < TransactionsController #ApplicationController

  # GET /incomes
  # GET /incomes.xml
  def index
    if params[:search].present?
      @incomes = Income.search(params)#.page(@page)
      p = params.dup
      p.delete(:option)
      @count = Income.search(p)
    else
      params[:option] ||= "all"
      @incomes = Income.find_with_state(params[:option])
      @count = Income.scoped
    end
  end

  # GET /incomes/1
  # GET /incomes/1.xml
  def show
    respond_to do |format|
      format.html { render 'transactions/show' }
      format.json  { render :json => @transaction }
    end
  end

  # GET /incomes/new
  # GET /incomes/new.xml
  def new
    if params[:transaction_id].present?
      t = Income.find(params[:transaction_id])
      @transaction = t.clone_transaction
    else
      @transaction = Income.new(date: Date.today, currency_id: currency_id)
      @transaction.set_defaults_with_details
    end
  end

  # GET /incomes/1/edit
  def edit
    render get_template(@transaction)
  end

  # POST /incomes
  # POST /incomes.xml
  def create
    @transaction = Income.new(income_params)

    respond_to do |format|
      if @transaction.save_trans
        format.html { redirect_to(@transaction, :notice => 'Se ha creado una proforma de venta.') }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
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

  # PUT /incomes/:id/approve_credit
  def approve_credit
    @transaction = Income.find(params[:id])
    if @transaction.approve_credit params[:income]
      flash[:notice] = "Se aprobó correctamente el crédito."
    else
      flash[:error] = "Existio un error al aprobar el crédito."
    end

    redirect_to @transaction
  end

  def approve_deliver
    @transaction = Income.find(params[:id])

    if @transaction.approve_deliver
      flash[:notice] = "Se aprobó la entrega de material."
    else
      flash[:error] = "Existio un error al aprobar la entrega de material."
    end
    
    redirect_to @transaction
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

  def income_params
    params.require(:income).permit(:ref_number, :date, :contact_id, :project_id,  :currency_id, 
                                   :exchange_rate, :discount, :bill_number, :description, :fact,
                                   :transaction_details_attributes)
  end
end
