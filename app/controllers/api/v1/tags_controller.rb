class Api::V1::TagsController < Api::V1::BaseController
  # GET /api/v1/tags
  def index
    render json: Tag.page(page).per(per)
  end

  # GET /api/v1/tags/count
  def count
    render json: { count: Tag.count }
  end
end
