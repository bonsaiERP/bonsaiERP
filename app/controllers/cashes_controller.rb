# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CashesController < ApplicationController
  before_filter :check_authorization!
  before_filter :set_cash, :only => [:show, :edit, :update, :destroy]
  # GET /cashs
  # GET /cashs.xml
  def index
    @cashes = Cash.org.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cashes }
    end
  end

  # GET /cashs/1
  # GET /cashs/1.xml
  def show
    @ledgers = @cash.account.get_ledgers.page(@page)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cash }
    end
  end

  # GET /cashs/new
  # GET /cashs/new.xml
  def new
    @cash = Cash.new(:currency_id => params[:currency_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cash }
    end
  end

  # GET /cashs/1/edit
  def edit
  end

  # POST /cashs
  # POST /cashs.xml
  def create
    @cash = Cash.new(params[:cash])

    respond_to do |format|
      if @cash.save
        format.html { redirect_to(@cash, :notice => 'La caja fue creada.') }
        format.xml  { render :xml => @cash, :status => :created, :location => @cash }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cashs/1
  # PUT /cashs/1.xml
  def update
    params[:cash].delete(:currency_id)

    respond_to do |format|
      if @cash.update_attributes(params[:cash])
        format.html { redirect_to(@cash, :notice => 'La caja fue actualizada.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cash.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cashs/1
  # DELETE /cashs/1.xml
  def destroy
    @cash.destroy

    respond_to do |format|
      format.html { redirect_to(cashs_url) }
      format.xml  { head :ok }
    end
  end

private
  def set_cash
    @cash = Cash.org.find(params[:id])
  end
end
