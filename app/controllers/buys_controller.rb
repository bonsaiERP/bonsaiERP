# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BuysController < ApplicationController

  before_filter :set_currency_rates, :only => [:index, :show]

  respond_to :html, :xml, :json
  # GET /buys
  # GET /buys.xml
  def index
    @buys = Buy.find_with_state(params[:option]).page(@page)
    respond_with @buys
  end

  # GET /buys/1
  # GET /buys/1.xml
  def show
    @buy = Buy.find(params[:id])
    respond_with(@buy)
  end

  # GET /buys/new
  # GET /buys/new.xml
  def new
    @buy = Buy.new(:date => Date.today, :discount => 0, :currency_exchange_rate => 1, :currency_id => currency_id )
    @buy.transaction_details.build
    respond_with(@buy)
  end

  # GET /buys/1/edit
  def edit
    @buy = Buy.find(params[:id])
  end

  # POST /buys
  # POST /buys.xml
  def create
    @buy = Buy.new(params[:buy])
    @buy.save
    respond_with(@buy)
  end

  # PUT /buys/1
  # PUT /buys/1.xml
  def update
    @buy = Buy.find(params[:id])
    @buy.update_attributes(params[:buy])
    respond_with(@buy)
  end

  # DELETE /buys/1
  # DELETE /buys/1.xml
  def destroy
    @buy = Buy.find(params[:id])
    @buy.destroy
    respond_with(@buy)
  end

private
  def set_currency_rates
    @currency_rates = {}
    CurrencyRate.active.each {|cr| @currency_rates[cr.currency_id] = cr.rate }
  end
end
