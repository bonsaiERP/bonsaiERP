# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class IncomesInventoryInsController < ApplicationController
  before_filter :set_store_and_income

  # GET
  # /incomes_inventory_ins/new?store_id=:store_id&income_id=:income_id
  def new
    @inv = Incomes::InventoryIn.new(
      store_id: @store.id, income_id: @income.id, date: Date.today,
      description: "Devolución mercadería ingreso #{ @income }"
    )
    @inv.build_details
  end

  # POST /incomes_inventory_ins
  # store_id&income_id=:income_id
  def create
    @inv = Incomes::InventoryIn.new({store_id: @store.id, income_id: @income.id}.merge(inventory_params))

    if @inv.create
      redirect_to show_movement_inventory_path(@inv.inventory.id), notice: "Se realizó la devolución de inventario para el ingreso #{@income}"
    else
      render :new
    end
  end

private
  def set_store_and_income
    @income = Income.active.find(params[:income_id])
    @store = Store.active.find(params[:store_id])
  rescue
    redirect_to incomes_path, alert: 'Ha seleccionado un almacen o un ingreso invalido' and return
  end

  def inventory_params
    params.require(:incomes_inventory_in).permit(
      :description, :date, :store_id, :income_id,
      inventory_details_attributes: [:item_id, :quantity]
    )
  end
end
