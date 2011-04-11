class InventoryOperationsController < ApplicationController
  # GET /inventory_operations
  # GET /inventory_operations.xml
  def index
    @inventory_operations = InventoryOperation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inventory_operations }
    end
  end

  # GET /inventory_operations/1
  # GET /inventory_operations/1.xml
  def show
    @inventory_operation = InventoryOperation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inventory_operation }
    end
  end

  # GET /inventory_operations/new
  # GET /inventory_operations/new.xml
  def new
    @inventory_operation = InventoryOperation.new(:store_id => params[:store_id], :operation => params[:operation])
    @inventory_operation.inventory_operation_details.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inventory_operation }
    end
  end

  # GET /inventory_operations/1/edit
  def edit
    @inventory_operation = InventoryOperation.find(params[:id])
  end

  # POST /inventory_operations
  # POST /inventory_operations.xml
  def create
    @inventory_operation = InventoryOperation.new(params[:inventory_operation])

    respond_to do |format|
      if @inventory_operation.save
        format.html { redirect_to(@inventory_operation, :notice => 'Inventory operation was successfully created.') }
        format.xml  { render :xml => @inventory_operation, :status => :created, :location => @inventory_operation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inventory_operation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_operations/1
  # PUT /inventory_operations/1.xml
  def update
    @inventory_operation = InventoryOperation.find(params[:id])

    respond_to do |format|
      if @inventory_operation.update_attributes(params[:inventory_operation])
        format.html { redirect_to(@inventory_operation, :notice => 'Inventory operation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inventory_operation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_operations/1
  # DELETE /inventory_operations/1.xml
  def destroy
    @inventory_operation = InventoryOperation.find(params[:id])
    @inventory_operation.destroy

    respond_to do |format|
      format.html { redirect_to(inventory_operations_url) }
      format.xml  { head :ok }
    end
  end

private
  def find_store
    store_id = params[:store_id] || params[:inventory_operation][:store_id]

    @store = Store.org.find(store_id)
  end
end
