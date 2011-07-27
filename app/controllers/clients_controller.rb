# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ClientsController < ApplicationController
  before_filter :check_authorization!
  before_filter :find_client, :only => [:show, :edit, :update, :destroy]

  #respond_to :html, :xml, :json
  # GET /clients
  # GET /clients.xml
  def index
    @clients = Client.org.page(@page)
  end

  # GET /clients/1
  # GET /clients/1.xml
  def show
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
        render :json => @client.attributes.merge( :account => @client.account.attributes )
      else
        redirect_to client_path(@client.id)
      end
    else
      render :action => 'new'
    end
  end

  # PUT /clients/1
  # PUT /clients/1.xml
  def update
    if @client.update_attributes(params[:client])
      redirect_ajax(@client)
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
