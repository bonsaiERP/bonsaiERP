# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  before_filter :set_item, :only => [:show, :edit, :update, :destroy]

  # GET /items
  def index
    if params[:search].present?
      @items = Item.search(params).page(@page)
    else
      @items = Item.includes(:unit, :stocks).page(@page)
    end
  end

  # GET /items/search?term=:term
  def search
    @items = Item.income.search(params[:term]).limit(20)

    respond_to do |format|
      format.json { render json: @items.to_json(methods: :label) }
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
      redirect_to @item, notice: 'Se ha creado el ítem correctamente.'
    else
      render :action => 'new'
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

  def item_params
    params.require(:item).permit(:code, :name, :active, :stockable,
                                 :for_sale, :price, :unit_id, :description)
  end
end
