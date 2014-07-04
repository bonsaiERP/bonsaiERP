class Api::V1::TagGroupsController < Api::V1::BaseController
  # GET /api/v1/tag_groups
  def index
    render json: TagGroup.page(page).per(per).to_json
  end

  # GET /api/v1/tag_groups/count
  def count
    render json: { count: TagGroup.count }
  end
end
