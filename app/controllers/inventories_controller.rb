# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoriesController < ApplicationController

  # GET /inventory_operations
  def index
    @inventory = Inventory.page(@page)
  end

  # GET /inventory_operations/1
  def show
    @inventory = present Inventory.find(params[:id])
  end


  # GET /inventory_operations/new_transaction
  def new_transaction
    @inventory_operation = Inventory.new(:store_id => params[:store_id], :operation => params[:operation], 
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

private

  def find_store
    store_id = params[:store_id] || params[:inventory_operation][:store_id]

    @store = Store.find(store_id)
  end

  # Checks the permission for different transactions
  def check_transaction_permission
    t_id      = params[:transaction_id] || params[:inventory_operation][:transaction_id]
    operation = params[:operation] || params[:inventory_operation][:operation]

    # Check correct params
    redirect_to "/404" unless t_id and Inventory::OPERATIONS.include?(operation)

    # Find transaction and check
    @transaction = Transaction.find(t_id)
    return redirect_to "/404" unless @transaction

    roles = User::ROLES.slice(0,2)

    case
      when ( @transaction.is_a?(Buy) && !(roles.include?(session[:user][:rol]) ) )
        redirect_to "/422"
      when ( @transaction.is_a?(Income) && operation === 'in' &&
          !(roles.include?(session[:user][:rol]) ) )
        redirect_to "/422"
    end

  end

end
