# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryInsController < ApplicationController
  before_filter :check_store

  def new
    @inv = Inventories::In.new(store_id: params[:store_id], date: Date.today,
                              description: "Ingreso de ítems")
    2.times { @inv.details.build }
  end

  def create
    @inv = Inventories::In.new(inventory_params.merge(store_id: params[:store_id]))

    if @inv.create
      redirect_to inventory_path(@inv.inventory.id), notice: 'Se ha ingresado correctamente los items.'
    else
      @inv.details.build if @inv.details.empty?
      render :new
    end
  end

private
  def check_store
    Store.find(params[:store_id])
  rescue
    flash[:error] = I18n.t('errors.messages.store.selected')
    redirect_to stores_path and return
  end

  def build_details
    @inv.details.build if @inv.details.empty?
  end

  def inventory_params
    params.require(:inventories_in).permit(
      :store_id, :date, :description,
      inventory_details_attributes: [:item_id, :quantity, :_destroy]
    )
  end
end
