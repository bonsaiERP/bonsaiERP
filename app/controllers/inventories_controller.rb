# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoriesController < ApplicationController
  include Controllers::Print

  before_filter :set_date_range, only: [:index]

  # GET /inventories
  def index
    @inventories = get_inventories
  end

  # GET /inventories/1
  def show
    @inventory = present Inventory.includes(inventory_details: :item).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show.print', "Inv-#{@inventory}" }
    end
  end

  # GET /inventories/1/show_movement
  def show_movement
    @inventory = present Inventory.includes(inventory_details: :item).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show_movement.print', "Inv-#{@inventory}" }
    end
  end

  # GET /inventories/1/show_trans
  def show_trans
    @inventory = present Inventory.includes(inventory_details: :item).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show_trans.print', "Inv-#{@inventory}" }
    end
  end

  private
    def get_inventories
      inv = Inventory.order("inventories.date desc, inventories.id desc")
      .includes(:store, :store_to, :income, :expense, :creator)
      if params[:search].present?
        s = params[:search]
        inv = inv.where{ref_number.like "%#{s}%"}
      elsif params[:search].blank? && params[:date_start].present?
        inv = inv.where(date: @date_range.range)
      end

      inv.page(@page)
    end

    def set_date_range
      if params[:date_start].present? && params[:date_end].present?
        @date_range = DateRange.parse(params[:date_start], params[:date_end])
      else
        @date_range = DateRange.default
      end
    end
end
