class AttachmentsController < ApplicationController

  # POST /attachments
  def create
    @attachment = Attachment.new(create_params)

    @attachment.save_attachment

    render json: @attachment
  end

  private

    def create_params
      params.require(:attachment)
        .permit(:attachable_id, :attachable_type, :attachment, :title)
    end
end
