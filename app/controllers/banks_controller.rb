# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BanksController < ApplicationController
  before_filter :check_authorization!
  before_filter :find_bank, :only => [:show, :edit, :update, :destroy]
  # GET /banks
  # GET /banks.xml
  def index
    @banks = Bank.org.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @banks }
    end
  end

  # GET /banks/1
  # GET /banks/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bank }
    end
  end

  # GET /banks/new
  # GET /banks/new.xml
  def new
    @bank = Bank.new(:currency_id => params[:currency_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bank }
    end
  end

  # GET /banks/1/edit
  def edit
  end

  # POST /banks
  # POST /banks.xml
  def create
    @bank = Bank.new(params[:bank])

    respond_to do |format|
      if @bank.save
        format.html { redirect_to(@bank, :notice => 'El banco fue creado. Por favor realice la concilición de la primera transacción para actualizar su saldo en cuenta') }
        format.xml  { render :xml => @bank, :status => :created, :location => @bank }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bank.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /banks/1
  # PUT /banks/1.xml
  def update
    respond_to do |format|
      if @bank.update_attributes(params[:bank])
        format.html { redirect_to(@bank, :notice => 'Banco actualizado.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bank.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /banks/1
  # DELETE /banks/1.xml
  #def destroy
  #  @bank.destroy
  #  respond_ajax @bank
  #end

  protected
    def find_bank
      @bank = Bank.org.find(params[:id])
    end
end
