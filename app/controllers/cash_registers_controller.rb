# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CashRegistersController < ApplicationController
  # GET /cash_registers
  # GET /cash_registers.xml
  def index
    @cash_registers = CashRegister.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cash_registers }
    end
  end

  # GET /cash_registers/1
  # GET /cash_registers/1.xml
  def show
    @cash_register = CashRegister.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cash_register }
    end
  end

  # GET /cash_registers/new
  # GET /cash_registers/new.xml
  def new
    @cash_register = CashRegister.new(:currency_id => params[:currency_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cash_register }
    end
  end

  # GET /cash_registers/1/edit
  def edit
    @cash_register = CashRegister.find(params[:id])
  end

  # POST /cash_registers
  # POST /cash_registers.xml
  def create
    @cash_register = CashRegister.new(params[:cash_register])

    respond_to do |format|
      if @cash_register.save
        format.html { redirect_to(@cash_register, :notice => 'CashRegister was successfully created.') }
        format.xml  { render :xml => @cash_register, :status => :created, :location => @cash_register }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cash_register.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cash_registers/1
  # PUT /cash_registers/1.xml
  def update
    @cash_register = CashRegister.find(params[:id])

    params[:cash_register].delete(:currency_id)

    respond_to do |format|
      if @cash_register.update_attributes(params[:cash_register])
        format.html { redirect_to(@cash_register, :notice => 'CashRegister was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cash_register.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_registers/1
  # DELETE /cash_registers/1.xml
  def destroy
    @cash_register = CashRegister.find(params[:id])
    @cash_register.destroy

    respond_to do |format|
      format.html { redirect_to(cash_registers_url) }
      format.xml  { head :ok }
    end
  end
end
