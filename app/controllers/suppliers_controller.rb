# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SuppliersController < ApplicationController
  before_filter :check_authorization!
  before_filter :find_supplier, :only => [:show, :edit, :update, :destroy]

  include Controllers::Contact

  #respond_to :html, :xml, :json
  # GET /suppliers
  # GET /suppliers.xml
  def index
    if params[:search]
      @suppliers = Supplier.org.search(params[:search]).order("matchcode ASC").page(@page)
    else
      @suppliers = Supplier.org.order("matchcode ASC").page(@page)
    end
  end

  # GET /suppliers/1
  # GET /suppliers/1.xml
  def show
    super @supplier
  end

  # GET /suppliers/new
  # GET /suppliers/new.xml
  def new
    @supplier = Supplier.new
  end

  # GET /suppliers/1/edit
  def edit
  end

  # POST /suppliers
  # POST /suppliers.xml
  def create
    @supplier = Supplier.new(params[:supplier])

    if @supplier.save
      if request.xhr?
        render :json => @supplier#.to_json( :methods => [:account_id, :account_name] )
      else
        redirect_to @supplier
      end
    else
      render :action => 'new'
    end
  end

  # PUT /suppliers/1
  # PUT /suppliers/1.xml
  def update
    if @supplier.update_attributes(params[:supplier])
      redirect_to @supplier
    else
      render :action => 'edit'
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.xml
  def destroy
    @supplier.destroy
    respond_ajax(@supplier)
  end

  protected
  def find_supplier
    @supplier = Supplier.org.find(params[:id])
  end
end

