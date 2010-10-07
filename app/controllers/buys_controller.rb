# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BuysController < ApplicationController
  respond_to :html, :xml, :json
  # GET /buys
  # GET /buys.xml
  def index
    case(params[:type])
      when 'pay'
        @buys = Buy.pay
      when 'aprove'
        @buys = Buy.aprove
      else
        @buys = Buy.all
    end
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
    @buy = Buy.new
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
end
