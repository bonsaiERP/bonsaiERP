# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class UnitsController < ApplicationController
  respond_to :html, :json, :xml

  before_filter :check_authorization!
  before_filter :check_organisation


  # GET /units
  # GET /units.xml
  def index
    @units = Unit.scoped
  end

  # GET /units/1
  # GET /units/1.xml
  def show
    @unit = Unit.find(params[:id])
    respond_with @unit
  end

  # GET /units/new
  # GET /units/new.xml
  def new
    @unit = Unit.new
    respond_with @unit
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
  end

  # POST /units
  # POST /units.xml
  def create
    @unit = Unit.new(params[:unit])

    if @unit.save
      redirect_ajax @unit
    else
      render :action => 'new'
    end
  end

  # PUT /units/1
  # PUT /units/1.xml
  def update
    @unit = Unit.find(params[:id])
    @unit.update_attributes(params[:unit])
    respond_with @unit
  end

  # DELETE /units/1
  # DELETE /units/1.xml
  def destroy
    @unit = Unit.find(params[:id])
    @unit.destroy
    if @unit.destroyed?
      flash[:notice] = "La unidad de medidad fue borrada."
    else
      flash[:error] = "No es posible borrar la unidad de medida."
    end

    respond_to do |format|
      format.html { redirect_to(units_url) }
      format.xml  { head :ok }
    end
  end
end
