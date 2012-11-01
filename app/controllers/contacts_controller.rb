# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactsController < ApplicationController
  before_filter :find_contact, :only => [:show, :edit, :update, :destroy]

  #respond_to :html, :xml, :json
  # GET /contacts
  # GET /contacts.xml
  def index
    @contacts = Contact.where().page(@page)

    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      redirect_ajax(@contact)
    else
      render :action => 'new'
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    if @contact.update_attributes(params[:contact])
      redirect_ajax(@contact)
    else
      render :action => 'edit'
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact.destroy
    respond_ajax(@contact)
  end

private
  def find_contact
    @contact = Contact.find(params[:id])
  end
end
