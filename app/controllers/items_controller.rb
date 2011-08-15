# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  respond_to :html, :json, :xml

  before_filter :check_authorization!
  before_filter :set_item, :only => [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.xml
  def index
    if params[:search].present?
      @items = Item.search(params).page(@page)
    else
      @items = Item.org.includes(:unit, :stocks).page(@page)
    end
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
    @item = Item.org.new
    respond_with @item
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])

    if @item.save
      if request.xhr?
        render :json => @item
      else
        redirect_to @item
      end
    else
      render :action => 'new'
    end
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
    options = {
      :notice => "Se ha eliminado el ítem correctamente",
      :error => "No se pudo eliminar el ítem: " + @item.errors[:base].join(", ")
    }

    redirect_ajax @item, options
  end

private
  def set_item
    @item = Item.org.find(params[:id])
  end
end
