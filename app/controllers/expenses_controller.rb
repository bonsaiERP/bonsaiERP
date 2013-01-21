# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ExpensesController < ApplicationController

  # GET /expenses
  def index
    if params[:search].present?
      @expenses = Expense.search(params)
      p = params.dup
      p.delete(:option)
      @count = Expense.search(p)
    else
      params[:option] ||= "all"
      @expenses = Expense.find_with_state(params[:option])
      @count = Expense.scoped
    end

    @expenses = @expenses.order('transactions.date DESC, transactions.id DESC').page(@page)
  end

  # GET /expenses/1
  def show
    respond_to do |format|
      format.html { render 'transactions/show' }
      format.json  { render :json => @transaction }
    end
  end

  # GET /expenses/new
  def new
    if params[:transaction_id].present?
      t = Expense.find(params[:transaction_id])
      @transaction = t.clone_transaction
    else
      @transaction = Expense.new(date: Date.today, currency_id: currency_id)
      @transaction.set_defaults_with_details
    end
  end

  # GET /expenses/1/edit
  def edit
    render get_template(@transaction)
  end

  # POST /expenses
  def create
    @transaction = Expense.new(expense_params)

    respond_to do |format|
      if @transaction.save_trans
        format.html { redirect_to(@transaction, :notice => 'Se ha creado una proforma de venta.') }
      else
        @transaction.transaction_details.build unless @transaction.transaction_details.any?
        format.html { render :action => "new" }
      end
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

  # PUT /expenses/1
  def update
    @transaction.attributes = params[:expense]
    if @transaction.save_trans
      redirect_to @transaction, :notice => 'La proforma de venta fue actualizada!.'
    else
      @transaction.transaction_details.build unless @transaction.transaction_details.any?
      render get_template(@transaction)
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

  # PUT /expenses/:id/approve_credit
  def approve_credit
    @transaction = Expense.find(params[:id])
    if @transaction.approve_credit params[:expense]
      flash[:notice] = "Se aprobó correctamente el crédito."
    else
      flash[:error] = "Existio un error al aprobar el crédito."
    end

    redirect_to @transaction
  end

  def approve_deliver
    @transaction = Expense.find(params[:id])

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
    @transaction = @history.get_transaction("Expense")

    render "transactions/history"
  end

private

  # Redirects in case that someone is trying to edit or destroy an  approved expense
  def redirect_expense
    flash[:warning] = "No es posible editar una nota ya aprobada!."
    redirect_to expenses_path
  end

  def set_transaction
    @transaction = Expense.find(params[:id])
    check_edit if ["edit", "update"].include?(params[:action])
  end

  # Checks for transactions to edit
  def check_edit
    unless allow_transaction_action?(@transaction)
      flash[:warning] = "No es posible editar la nota de venta."
      return redirect_to @transaction
    end
  end

  def expense_params
    params.require(:expense).permit(:ref_number, :date, :contact_id, :project_id,  :currency_id, 
                                   :exchange_rate, :discount, :bill_number, :description, :fact,
                                   :transaction_details_attributes)
  end

private
  def quick_expense_params
    params.require(:quick_expense).permit(:date, :ref_number, :fact,
                                        :bill_number, :amount,
                                        :contact_id, :account_id, )
  end
end
