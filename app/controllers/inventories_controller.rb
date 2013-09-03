# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoriesController < ApplicationController
  include Controllers::Print

  # GET /inventory_operations
  def index
    @inventory = Inventory.page(@page)
  end

  # GET /inventories/1
  def show
    @inventory = present Inventory.includes(inventory_details: {item: :unit}).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show.print', "Inv-#{@inventory}" }
    end
  end

  # GET /inventories/1/show_movement
  def show_movement
    @inventory = present Inventory.includes(inventory_details: {item: :unit}).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show_movement.print', "Inv-#{@inventory}" }
    end
  end

  # GET /inventories/1/show_trans
  def show_trans
    @inventory = present Inventory.includes(inventory_details: {item: :unit}).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show_trans.print', "Inv-#{@inventory}" }
    end
  end
end
