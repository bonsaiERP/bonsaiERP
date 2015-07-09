# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StoresController < ApplicationController
  before_action :set_date_range, :set_show_params, only: ['show']

  # GET /stores
  def index
    @stores = present Store.all

    respond_to do |format|
      format.html
    end
  end

  # GET /stores/1
  def show
    @store = present Store.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  # GET /stores/new
  def new
    @store = Store.new(active: true)

    respond_to do |format|
      format.html
    end
  end

  # GET /stores/1/edit
  def edit
    @store = Store.find(params[:id])
  end

  # POST /stores
  def create
    @store = Store.new(store_params)

    if @store.save
      redirect_ajax(@store, :notice => 'El almacen fue correctamente creado.')
    else
      render :action => "new"
    end
  end

  # PUT /stores/1
  def update
    @store = Store.find(params[:id])

    respond_to do |format|
      if @store.update_attributes(store_params)
        format.html { redirect_to(@store, notice: 'El almacen fue correctamente actualizado.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.xml
  def destroy
    @store = Store.find(params[:id])
    @store.destroy

    if @store.destroyed?
      flash[:notice] = "El almacen fue eliminado."
      redirect_to stores_path
    else
      flash[:warning] = "El almacen no puede ser eliminado debido a que tiene datos relacionados."
      redirect_to @store
    end

  end

  private

    def store_params
      params.require(:store).permit(:name, :active, :phone, :address)
    end

    def get_partial
      case params[:tab]
      when "operations"
        @operations = @store.inventory_operations.includes(:creator).order("created_at DESC").page(@page)
        "operations"
      else
        params[:option] ||= 'all'
        case
        when params[:option] === "minimum"
          @items = @store.stocks.minimums.page(@page)
        else
          @items = @store.stocks.includes(:item).order("(stocks.minimum - stocks.quantity) DESC").page(@page)
        end
        params[:tab] = "items"
        "items"
      end
    end

    def set_date_range
      if params[:commit_operations]
        @date_range = DateRange.parse(params[:date_start], params[:date_end])
      else
        @date_range = DateRange.default
      end
    end

    def set_show_params
      unless params[:items_commit] || params[:commit_operations]
        params[:all] = 1  unless [:minimum_inventory].any? {|v| params[v].present? }
      end
    end
end
