# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CashesController < ApplicationController
  before_filter :set_cash, :only => [:show, :edit, :update, :destroy]

  include Controllers::Money

  # GET /cashs
  def index
    @cashes = Cash.order('name asc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cashes }
    end
  end

  # GET /cashs/1
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cash }
    end
  end

  # GET /cashs/new
  def new
    @cash = Cash.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cash }
    end
  end

  # GET /cashs/1/edit
  def edit
  end

  # POST /cashs
  def create
    @cash = Cash.new(cash_params)

    respond_to do |format|
      if @cash.save
        format.html { redirect_to(cash_path(@cash), notice: 'La cuenta efectivo fue creada.') }
      else
        format.html { render :new }
      end
    end
  end

  # PUT /cashs/1
  def update
    params[:cash].delete(:currency_id)

    respond_to do |format|
      if @cash.update_attributes(cash_params)
        format.html { redirect_to(@cash, :notice => 'La caja fue actualizada.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cashs/1
  def destroy
    @cash.destroy

    respond_to do |format|
      format.html { redirect_to(cashs_url) }
      format.xml  { head :ok }
    end
  end

  private

    def set_cash
      @cash = Cash.find(params[:id])
    end

    def cash_params
      params.require(:cash).permit(:name, :currency, :amount, :address)
    end
end
