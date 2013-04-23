# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactsController < ApplicationController
  before_filter :find_contact, :only => [:show, :edit, :update, :destroy]

  #respond_to :html, :json
  # GET /contacts
  def index
    if search_term.present?
      @contacts = Contact.search(search_term).order('matchcode asc').page(@page)
    else
      @contacts = Contact.order('matchcode asc').page(@page)
    end

    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    respond_to do |format|
      format.html
      format.json { render json: @contact }
      format.js { render 'show', format: 'js' }
    end
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
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_ajax(@contact, notice: 'Se ha creado el contacto.')
    else
      render 'new'
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    if @contact.update_attributes(contact_params)
      redirect_ajax(@contact)
    else
      render :action => 'edit'
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact.destroy

    #respond_ajax(@contact)
    if @contact.destroyed?
      flash[:success] = 'El contacto fue eliminado'
    else
      flash[:error] = 'No fue posible eliminar el contacto'
    end
    redirect_to contacts_path
  end

private
  def find_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:matchcode, :first_name, :last_name, :email, :phone, :mobile, :tax_number, :address)
  end
end
