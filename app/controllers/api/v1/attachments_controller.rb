class Api::V1::AttachmentsController < Api::V1::BaseController
  # GET /api/v1/attachments
  def index
    render json: Attachment.page(page).per(per).map(&:to_api).to_json
  end

  # GET /api/v1/attachments/:id
  def show
    attachment = Attachment.find(params[:id])

    render json: attachment.to_api.to_json
  end

  # GET /api/v1/attachments/count
  def count
    render json: { count: Attachment.count }
  end

end
