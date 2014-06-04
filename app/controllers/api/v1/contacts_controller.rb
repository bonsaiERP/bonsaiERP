class Api::V1::ContactsController < Api::V1::BaseController
  # GET /api/v1/contacts
  def index
    render json: Contact.page(page).to_json
  end
end
