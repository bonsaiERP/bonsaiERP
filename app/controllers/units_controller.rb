# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class UnitsController < ApplicationController
  respond_to :html, :json, :xml, :js
  before_filter :check_organisation


  # GET /units
  # GET /units.xml
  def index
    @units = Unit.org
    respond_with @units
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
    @unit = Unit.create(params[:unit])
    respond_with @unit
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

    respond_to do |format|
      format.html { redirect_to(units_url) }
      format.xml  { head :ok }
    end
  end
end
