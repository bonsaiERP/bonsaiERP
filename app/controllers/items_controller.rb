# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  include Controllers::TagSearch

  before_filter :set_item, :only => [:show, :edit, :update, :destroy]

  # GET /items
  def index
    search_items

    respond_to do |format|
      format.html
      format.json { render json: @items }
    end
  end

  # Search for income items
  # GET /items/search_income?term=:term
  def search_income
    @items = ItemQuery.new.income_search(params[:term]).limit(20)

    respond_to do |format|
      format.json { render json: @items }
    end
  end

  # Search for expense items
  # GET /items/search_expense?term=:term
  def search_expense
    @items = ItemQuery.new.expense_search(params[:term]).limit(20)

    respond_to do |format|
      format.json { render json: @items }
    end
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new(stockable: true)
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_ajax @item, notice: 'Se ha creado el ítem correctamente.'
    else
      render 'new'
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
  # DELETE /items/1.xml
  def destroy
    @item.destroy

    redirect_ajax @item
  end

  private

    def set_item
      @item = Item.find(params[:id])
    end

    def search_items
      @items = Item.includes(:unit, :stocks)
      @items = @items.for_sale  if params[:for_sale].present?
      @items = @items.search(search_term).includes(:unit)  if search_term.present?
      @items = @items.all_tags(*tag_ids)  if params[:search] && has_tags?

      @items = @items.order('name asc').page(@page)
    end

    def item_params
      params.require(:item).permit(:code, :name, :active, :stockable,
                                   :for_sale, :price, :buy_price, :unit_id, :description)
    end
end
