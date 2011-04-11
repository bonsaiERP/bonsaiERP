# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  respond_to :html, :json, :xml
  before_filter :set_item, :only => [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.xml
  def index
    @items = Item.org.includes(:unit).page(@page)#Item.where(:ctype => @ctype).includes(:unit)
    respond_with @items
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    respond_with @item
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.org.new#(:ctype => params[:ctype])
    respond_with @item
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])
    @item.save
    respond_with @item
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item.update_attributes(params[:item])
    flash[:notice] = "Se actualizo correctamente el ítem"
    respond_with @item
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
