class Api::V1::TagsController < Api::V1::BaseController
  # GET /api/v1/tags
  def index
    render json: Tag.page(page).to_json
  end
end
