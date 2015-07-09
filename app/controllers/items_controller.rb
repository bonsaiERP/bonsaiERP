# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  include Controllers::TagSearch

  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  def index
    search_items

    respond_to do |format|
      format.html
      format.json { render json: @items}
    end
  end

  # Search for income items
  # GET /items/search_income?term=:term
  def search_income
    @items = Item.income.search(params[:term]).limit(20)

    render json: ItemSerializer.new.income(@items)
  end

  # Search for expense items
  # GET /items/search_expense?term=:term
  def search_expense
    @items = Item.active.search(params[:term]).limit(20)

    render json: ItemSerializer.new.expense(@items)
  end

  # GET /items/:store_id/search_inventory
  def search_inventory
    @items = Item.active.search(params[:term]).limit(20)

    render json: ItemSerializer.new.inventory(@items, params[:id])
  end

  # GET /items/1 show action

  # GET /items/new
  def new
    @item = Item.new(new_attrs)
  end

  # GET /items/1/edit

  # POST /items
  def create
    @item = Item.new(item_params)

    if @item.save
      render_or_redirect_item
    else
      render :new
    end
  end

  # PUT /items/1
  def update
    if @item.update_attributes(item_params)
      flash[:notice] = "Se actualizo correctamente el ítem."
      redirect_ajax @item
    else
      render :edit
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy

    redirect_ajax @item
  end

  private

    def set_item
      @item = Item.find(params[:id])
    end

    def search_items
      filter_params
      @items = Item.includes(:unit, :stocks)
      @items.where!(for_sale: for_sale_param)  if params[:for_sale].present?
      @items.where!(active: params[:active])  if params[:active].present?
      @items = @items.search(search_term)  if search_term.present?
      @items = @items.any_tags(*tag_ids)  if tag_ids

      @items = @items.order('items.name asc').page(@page)
    end

    def filter_params
      params[:all] = true  if params[:for_sale].blank?
    end

    def for_sale_param
      ['true', true, '1', 1].include?(params.fetch(:for_sale)) == true ? true : false
    end

    def item_params
      params.require(:item).permit(:code, :name, :active, :stockable,
                                   :for_sale, :price, :buy_price, :unit_id, :description)
    end

    def render_or_redirect_item
      if request.xhr?
        if params[:for_sale] == 'true'
          render json: ItemSerializer.new.income([@item]).first
        else
          render json: ItemSerializer.new.expense([@item]).first
        end
      else
        redirect_to @item, notice: 'Se ha creado el ítem correctamente.'
      end
    end

    def new_attrs
      if params[:for_sale] === 'false'
        {for_sale: false}
      else
        {}
      end
    end
end
