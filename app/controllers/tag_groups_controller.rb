class TagGroupsController < ApplicationController

  # GET /tag_groups
  def index
    @tag_groups = TagGroup.order(:name).page(@page)
  end

  # GET /tag_groups/new
  def new
    @tag_group = TagGroup.new
  end

  # POST /tag_groups
  def create
    tag_group = TagGroup.new(tag_group_params)

    if tag_group.save
      render json: tag_group
    else
      render json: { errors: tag_group.errors }, status: 409
    end
  end

  # GET /tag_groups/:id/edit
  def edit
    @tag_group = TagGroup.find(params[:id])
  end

  # PATCH, PUT /tag_groups/:id
  def update
    tag_group = TagGroup.find(params[:id])

    if tag_group.update(tag_group_params)
      render json: tag_group
    else
      render json: { errors: tag_group.errors }, status: 409
    end
  end

  private

    def tag_group_params
      params.require(:tag_group)
        .permit(:name, tag_ids: [])
    end
end
