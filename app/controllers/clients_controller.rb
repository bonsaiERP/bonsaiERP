# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ClientsController < ApplicationController
  before_filter :check_authorization!
  before_filter :find_client, :only => [:show, :edit, :update, :destroy]

  include Controllers::Contact

  #respond_to :html, :xml, :json
  # GET /clients
  # GET /clients.xml
  def index
    if params[:search]
      @clients = Client.org.search(params[:search]).page(@page)
    else
      @clients = Client.org.page(@page)
    end
  end

  # GET /clients/1
  # GET /clients/1.xml
  def show
    super @client
  end

  # GET /clients/new
  # GET /clients/new.xml
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.xml
  def create
    @client = Client.new(params[:client])

    if @client.save
      if request.xhr?
        render :json => @client# @client.to_json( :methods => [:account_id, :account_name] )
      else
        redirect_to @client.account
      end
    else
      render :action => 'new'
    end
  end

  # PUT /clients/1
  # PUT /clients/1.xml
  def update
    if @client.update_attributes(params[:client])
      redirect_to @client
    else
      render :action => 'edit'
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.xml
  def destroy
    @client.destroy
    redirect_ajax(@client)
  end

  protected
  def find_client
    @client = Client.org.find(params[:id])
  end
end
