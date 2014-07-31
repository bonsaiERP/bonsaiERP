# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactsController < ApplicationController
  include Controllers::TagSearch
  before_filter :find_contact, only: [:show, :edit, :update, :destroy, :incomes, :expenses]

  # GET /contacts
  def index
    @contacts = Contacts::Query.new.index.order('matchcode asc')

    @contacts = @contacts.any_tags(*tag_ids)  if tag_ids
    @contacts = @contacts.search(search_term)  if search_term

    @contacts = @contacts.page(@page)

    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1
  def show
    params[:operation] ||= 'all'
    @contact = present @contact
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit

  # POST /contacts
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_ajax(@contact, notice: 'Se ha creado el contacto.')
    else
      render :new
    end
  end

  # PUT /contacts/1
  def update
    if @contact.update_attributes(contact_params)
      redirect_ajax(@contact)
    else
      render :edit
    end
  end

  # DELETE /contacts/1
  def destroy
    @contact.destroy

    if @contact.destroyed?
      flash[:notice] = 'El contacto fue eliminado'
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

    def search_term
      @search_term ||= params[:search] || params[:term]
    end
end
