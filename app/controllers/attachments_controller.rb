class AttachmentsController < ApplicationController
  before_action :set_attachment, only: [:show, :update, :destroy]

  # POST /attachments
  def create
    @attachment = Attachment.new(create_params)
    @attachment.save_attachment

    render json: @attachment
  end

  # PATCH /attachments/:id
  def update
    if @attachment.update(position: params[:position])
      render json: @attachment
    else
      render json: { errors: @attachment.errors }, status: STATUS_ERROR
    end
  end

  def destroy
    if @attachment.destroy
      render json: @attachment
    else
      render json: @attachment, status: STATUS_ERROR
    end
  end

  private

    def create_params
      params.permit(:attachable_id, :attachable_type, :position)
        .merge(attachment: params[:file])
    end

    def set_attachment
      @attachment = Attachment.find(params[:id])
    end
end
