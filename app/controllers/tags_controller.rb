# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TagsController < ApplicationController

  # GET /tags/new
  #def new
  #  @tag = Tag.new
  #end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: @tag
    else
      render json: { errors: @tag.errors }, status: 409
    end
  end

  # PUT /tags/:id
  def update
    @tag = Tag.find(params[:id])

    if @tag.update_attributes(tag_params)
      render json: @tag
    else
      render json: {errors: @tag.errors}, status: 409
    end
  end

  # PATCH /tags/update_models
  def update_models
    Tag.update_models(update_models_params)

    render json: {success: true}
  rescue
    render json: {success: false}
  end

  private

    def tag_params
      params.require(:tag).permit(:name, :bgcolor)
    end

    def update_models_params
      params.slice(:model, :tag_ids, :ids)
    end
end
