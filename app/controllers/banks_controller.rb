# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BanksController < ApplicationController
  before_filter :find_bank, :only => [:show, :edit, :update, :destroy]

  include Controllers::Money

  # GET /banks
  def index
    @banks = Bank.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @banks }
    end
  end

  # GET /banks/1
  # GET /banks/1.xml
  def show
    @account = @bank.account
    @ledgers = super(@account)
    @paged_ledgers = @ledgers.page(@page)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bank }
    end
  end

  # GET /banks/new
  def new
    @bank = Bank.new(currency: params[:currency])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bank }
    end
  end

  # GET /banks/1/edit
  def edit
  end

  # POST /banks
  def create
    @bank = Bank.new(create_bank_params)

    respond_to do |format|
      if @bank.save
        format.html { redirect_to(@bank, :notice => 'La cuenta bancaria fue creada.') }
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
        format.html { redirect_to(@bank, :notice => 'Los datos de la cuenta Bancaria fueron actualizado.') }
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

private
  def find_bank
    @bank = Bank.includes(:account).find(params[:id])
  end

  def update_bank_params
    params.require(:bank).permit(:name, :number, :address, :phone, :website)
  end

  def create_bank_params
    params.require(:bank).permit(:name, :number, :address, :phone, :website, :currency, :amount)
  end
end
