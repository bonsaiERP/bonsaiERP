# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryTransferencesController < ApplicationController
  before_filter :set_store, only: [:new, :create]

  # GET /inventory_transferences/new
  def new
    @trans = Inventories::Transference.new(store_id: @store.id, date: Date.today)

    2.times { @trans.details.build }
  end

  # GET /inventory_transferences/new
  def create
    @trans = Inventories::Transference.new(trans_params)

    if @trans.create
      redirect_to show_trans_inventory_path(@trans.inventory.id), notice: 'Se ha realizado correctamente la transferencia.'
    else
      render :new
    end
  end

  # GET /inventory_transferences/:id
  # Search for available items in a store
  def show
    render json: items_hash
  end

  private

    def items_hash
      stocks.map {|st| {id: st.item_id, label: st.item.to_s, unit: st.item.unit_symbol, quantity: st.quantity} }
    end

    def stocks
      Stock.available_items(params[:id], params[:term]).order("items.name").limit(20)
    end

    def trans_params
      params.require(:inventories_transference)
      .permit(:store_id, :store_to_id, :date, :description,
              inventory_details_attributes: [:item_id, :quantity])
    end

    def set_store
      @store = Store.active.find(params[:store_id])
    rescue
      redirect_to stores_path, error: 'Debe seleccionar un almacen activo.'
    end
end
