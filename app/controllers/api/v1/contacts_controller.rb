class Api::V1::ContactsController < Api::V1::BaseController
  # GET /api/v1/contacts
  def index
    render json: Contact.page(page).per(per).to_json
  end

  # POST /api/v1/contacts
  # JSON must be
  # {contact: {matchcode: 'Nmame', first_name: 'First'}}
  def create
    contact = Contact.new(contact_params)

    if contact.save
      render json: contact.to_json
    else
      render json: contact.errors, status: 409
    end
  end

  # PATCH /api/v1/contacts/:id

  # GET /api/v1/contacts/count
  def count
    render json: { count: Contact.count }
  end

  private

    def contact_params
      params.require(:contact).permit(:matchcode, :first_name, :last_name, :email,
                                      :phone, :mobile, :tax_number, :address, tag_ids: [])
    end
end
