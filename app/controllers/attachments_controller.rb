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
    case
    when move_up?
      @attachment.move_up(position)
    when move_down?
      @attachment.move_down(position)
    else
      render json: @attachment, status: STATUS_ERROR
    end

    render json: @attachment
  rescue
    render json: {error: true}, status: STATUS_ERROR
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

    def move_up?
      !!(params[:attachment][:move] === 'up' && position)
    end

    def move_down?
      !!(params[:attachment][:move] === 'down' && position)
    end

    def position
      if params[:attachment][:position].to_s.match(/\A\d+\z/)
        params[:attachment][:position].to_s.to_i
      else
        nil
      end
    end

    def set_attachment
      @attachment = Attachment.find(params[:id])
    end
end
