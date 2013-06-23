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
      render json: {errors: @tag.errors}
    end
  end

private
  def tag_params
    params.require(:tag).permit(:name, :bgcolor)
  end
end
