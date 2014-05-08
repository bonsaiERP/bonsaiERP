# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class UnitsController < ApplicationController
  respond_to :html, :json

  # GET /units
  def index
    @units = Unit.all
  end

  # GET /units/1
  def show
    @unit = Unit.find(params[:id])
    respond_with @unit
  end

  # GET /units/new
  def new
    @unit = Unit.new
    #respond_with @unit
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
  end

  # POST /units
  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      redirect_ajax @unit
    else
      if request.xhr?
        render json: @unit.errors
      else
        render :new
      end
    end
  end

  # PUT /units/1
  def update
    @unit = Unit.find(params[:id])
    @unit.update_attributes(unit_params)

    respond_with @unit
  end

  # DELETE /units/1
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
    end
  end

  private

    def unit_params
      params.require(:unit).permit(:name, :symbol)
    end
end
