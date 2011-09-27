# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperationsController < ApplicationController
  before_filter :check_authorization!
  before_filter :check_transaction_permission, :only => [:new_transaction, :create_transaction]

  # GET /inventory_operations
  # GET /inventory_operations.xml
  def index
    @inventory_operations = InventoryOperation.org.page(@page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inventory_operations }
    end
  end

  # GET /inventory_operations/1
  # GET /inventory_operations/1.xml
  def show
    @inventory_operation = InventoryOperation.org.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inventory_operation }
    end
  end

  # GET /inventory_operations/new
  # GET /inventory_operations/new.xml
  def new
    @inventory_operation = InventoryOperation.new(:store_id => params[:store_id], :operation => params[:operation])
    @inventory_operation.create_details
    @inventory_operation.create_ref_number

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inventory_operation }
    end
  end

  # GET /inventory_operations/1/edit
  #def edit
  #  @inventory_operation = InventoryOperation.find(params[:id])
  #end

  # TODO: Iprove security
  # POST /inventory_operations
  # POST /inventory_operations.xml
  def create
    @inventory_operation = InventoryOperation.new(params[:inventory_operation])

    respond_to do |format|
      if @inventory_operation.save_operation
        format.html { redirect_to(@inventory_operation, :notice => 'La operación de inventario fue almacenada correctamente.') }
        format.xml  { render :xml => @inventory_operation, :status => :created, :location => @inventory_operation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inventory_operation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /inventory_operations/new_transaction
  def new_transaction
    @inventory_operation = InventoryOperation.new(:store_id => params[:store_id], :operation => params[:operation], 
                                                  :transaction_id => params[:transaction_id])

    @inventory_operation.set_transaction
  end

  # /inventory_operations/create_transaction
  def create_transaction
    @inventory_operation = @transaction.inventory_operations.build(params[:inventory_operation])
    @inventory_operation.contact_id = @transaction.contact_id

    if @inventory_operation.save_transaction
      redirect_to(@inventory_operation, :notice => 'La operación de inventario fue almacenada correctamente.')
    else
      render :action => "new_transaction"
    end
  end


  # Selects a store for in out of a transaction
  def select_store
    @transaction = Transaction.org.find(params[:id])
  end

  # Presents the transactions that are IN/OUT
  def transactions
    @currency_rates = CurrencyRate.current_hash
    params[:operation] = "in" unless ["in", "out"].include?( params[:operation] )

    if params[:operation] == "out"
      @transactions = Income.org.inventory.order("created_at DESC").page(@page)
    else
      redirect_to "/422" unless User::ROLES.slice(0,2).include? session[:user][:rol]
      @transactions = Buy.org.inventory.order("created_at DESC").page(@page)
    end
  end

  private

  def find_store
    store_id = params[:store_id] || params[:inventory_operation][:store_id]

    @store = Store.org.find(store_id)
  end

  # Checks the permission for different transactions
  def check_transaction_permission
    t_id      = params[:transaction_id] || params[:inventory_operation][:transaction_id]
    operation = params[:operation] || params[:inventory_operation][:operation]

    # Check correct params
    redirect_to "/404" unless t_id and InventoryOperation::OPERATIONS.include?(operation)

    # Find transaction and check
    @transaction = Transaction.org.find(t_id)
    return redirect_to "/404" unless @transaction

    roles = User::ROLES.slice(0,2)

    case
      when ( @transaction.is_a?(Buy) and not(roles.include?(session[:user][:rol]) ) )
        redirect_to "/422"
      when ( @transaction.is_a?(Income) and operation === 'in' and
          not(roles.include?(session[:user][:rol]) ) )
        redirect_to "/422"
    end

  end

end
