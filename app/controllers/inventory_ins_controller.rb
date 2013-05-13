# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryInsController < ApplicationController
  before_filter :set_and_check_store

  def new
    @inv.ref_number = @inv.get_ref_number
  end

  def create
    if @inv.create
      redirect_to inventory_operation_path(@inv.inventory_operation.id), notice: 'Se ha ingresado correctamente los items.'
    else
      @inv.ref_number = @inv.get_ref_number
      render :new
    end
  end

private
  def set_and_check_store
    build_inventory_in

    unless @inv.store
      flash[:error] = I18n.t('errors.messages.store.selected')
      redirect_to stores_path and return
    end
  end

  def build_inventory_in
    data = action_name === 'new' ? {store_id: params[:store_id]} : inventory_params
    @inv = InventoryIn.new(data)

    @inv.items.build if @inv.items.empty?
  end

  def inventory_params
    params.require(:inventory_in).permit(
      :store_id, :date, :description,
      inventory_operation_details_attributes: [:item_id, :quantity, :_destroy]
    )
  end
end
