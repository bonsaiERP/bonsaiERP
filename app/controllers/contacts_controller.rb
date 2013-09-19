# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactsController < ApplicationController
  before_filter :find_contact, :only => [:show, :edit, :update, :destroy, :incomes, :expenses]

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
  def show
    @contact = present @contact
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_ajax(@contact, notice: 'Se ha creado el contacto.')
    else
      render 'new'
    end
  end

  # PUT /contacts/1
  def update
    if @contact.update_attributes(contact_params)
      redirect_ajax(@contact)
    else
      render :action => 'edit'
    end
  end

  # DELETE /contacts/1
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

  # GET /contacts/:id/expenses
  def expenses
    params[:page_expenses] ||= 1
  end

  # GET /contacts/:id/incomes
  def incomes
    params[:page_incomes] ||= 1
  end

private
  def find_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:matchcode, :first_name, :last_name, :email, :phone, :mobile, :tax_number, :address)
  end
end
