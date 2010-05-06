# encoding: utf-8
class ContactsController < ApplicationController
  respond_to :html, :xml, :json
  # GET /contacts
  # GET /contacts.xml
  def index
    @contacts = Contact.all
    respond_with @contacts
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @contact = Contact.find(params[:id])
    respond_with(@contact)
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contact = Contact.new
    respond_with(@contact)
  end

  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Contact.new(params[:contact])
    @contact.save
    respond_with(@contact)
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:id])
    @contact.update_attributes(params[:contact])
    respond_with(@contact)
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    respond_with(@contact)
  end
end
