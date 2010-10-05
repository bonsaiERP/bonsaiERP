# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  respond_to :html, :json, :xml
  before_filter :set_ctype # Set the @ctype variable

  # GET /items
  # GET /items.xml
  def index
    @items = Item.where(:ctype => @ctype).includes(:unit).where(:visible => true)
    respond_with @items
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])
    respond_with @item
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new(:ctype => params[:ctype])
    respond_with @item
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
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
    @item = Item.find(params[:id])
    @item.update_attributes(params[:item])
    respond_with @item
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    respond_with @item
  end

private
  # Sets the type for the Item
  def set_ctype
    ctype = params[:ctype]
    # In case that is create or udpate method
    ctype = params[:item][:ctype] if request.post? or request.put?
    if Item::TYPES.include?(ctype)
      @ctype = params[:ctype]
    else
      @ctype = Item::TYPES[0]
    end
  end

end
