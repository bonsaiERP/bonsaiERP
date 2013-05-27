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
    @inventory = present Inventory.includes(inventory_details: {item: :unit}).find(params[:id])
  end
end
