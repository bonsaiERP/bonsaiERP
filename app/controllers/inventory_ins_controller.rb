# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryInsController < ApplicationController
  def new
    @inv = InventoryIn.new(store_id: params[:store_id])
    check_store
    @inv.items.build
  end

  def create
    @inv = InventoryIn.new(inventory_params)
    check_store

    if @inv.create
      redirect_to inventory_operation_path(@inv.inventory_operation.id), notice: 'Se ha ingresado correctamente los items.'
    else
      render :new
    end
  end

private
  def check_store
    unless @inv.store
      flash[:error] = I18n.t('errors.messages.store.selected')
      redirect_to stores_path and return
    end
  end

  def inventory_params
    params.require(:inventory_in).permit(
      :store_id, :date, :description
    )
  end
end
