# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StoresController < ApplicationController
  before_filter :check_authorization!
  # GET /stores
  # GET /stores.xml
  def index
    @stores = Store.org

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stores }
    end
  end

  # GET /stores/1
  # GET /stores/1.xml
  def show
    @store = Store.find(params[:id])
    @partial = get_partial

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @store }
    end
  end

  # GET /stores/new
  # GET /stores/new.xml
  def new
    @store = Store.new(:active => true)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @store }
    end
  end

  # GET /stores/1/edit
  def edit
    @store = Store.find(params[:id])
  end

  # POST /stores
  # POST /stores.xml
  def create
    @store = Store.new(params[:store])

    if @store.save
      redirect_ajax(@store, :notice => 'El almacen fue correctamente creado.')
    else
      render :action => "new"
    end
  end

  # PUT /stores/1
  # PUT /stores/1.xml
  def update
    @store = Store.find(params[:id])

    respond_to do |format|
      if @store.update_attributes(params[:store])
        format.html { redirect_to(@store, :notice => 'El almacen fue correctamente actualizado.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @store.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.xml
  def destroy
    @store = Store.find(params[:id])
    @store.destroy

    respond_to do |format|
      format.html { redirect_to(stores_url) }
      format.xml  { head :ok }
    end
  end

  private
    def get_partial
      case params[:tab]
      when "operations"
        @operations = @store.inventory_operations.includes(:transaction).order("date desc").page(@page)
        "operations"
      else
        @items = @store.stocks.includes(:item).page(@page)
        params[:tab] = "items"
        "items"
      end
    end
end
