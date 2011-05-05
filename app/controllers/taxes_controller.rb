# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TaxesController < ApplicationController
  before_filter :check_authorization!
  respond_to :html, :xml, :json, :js

  # GET /taxes
  # GET /taxes.xml
  def index
    @taxes = Tax.org.all
    respond_with @taxes
  end

  # GET /taxes/1
  # GET /taxes/1.xml
  def show
    @tax = Tax.org.find(params[:id])
    respond_with @tax
  end

  # GET /taxes/new
  # GET /taxes/new.xml
  def new
    @tax = Tax.new
    respond_with @tax
  end

  # GET /taxes/1/edit
  def edit
    @tax = Tax.org.find(params[:id])
  end

  # POST /taxes
  # POST /taxes.xml
  def create
    @tax = Tax.new(params[:tax])

    respond_to do |format|
      if @tax.save
        format.html { redirect_to(@tax, :notice => 'Tax was successfully created.') }
        format.xml  { render :xml => @tax, :status => :created, :location => @tax }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tax.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /taxes/1
  # PUT /taxes/1.xml
  def update
    @tax = Tax.find(params[:id])

    respond_to do |format|
      if @tax.update_attributes(params[:tax])
        format.html { redirect_to(@tax, :notice => 'Tax was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tax.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1
  # DELETE /taxes/1.xml
  #def destroy
  #  @tax = Tax.find(params[:id])
  #  @tax.destroy

  #  respond_to do |format|
  #    format.html { redirect_to(taxes_url) }
  #    format.xml  { head :ok }
  #  end
  #end
end
