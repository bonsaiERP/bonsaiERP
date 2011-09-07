# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController

  before_filter :check_authorization!
  before_filter :set_item, :only => [:show, :edit, :update, :destroy]

  # GET /items
  def index
    if params[:search].present?
      @items = Item.search(params).page(@page)
    else
      @items = Item.org.includes(:unit, :stocks).page(@page)
    end
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.org.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])

    if @item.save
      redirect_ajax @item
    else
      render :action => 'new'
    end
  end

  # PUT /items/1
  def update
    if @item.update_attributes(params[:item])
      flash[:notice] = "Se actualizo correctamente el ítem"
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
    @item = Item.org.find(params[:id])
  end
end
