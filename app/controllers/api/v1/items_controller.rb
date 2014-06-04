class Api::V1::ItemsController < Api::V1::BaseController

  # GET /api/v1/items
  def index
    render json: search_items.to_json
  end

  private

    def search_items
      items = Item

      items = items.where(active: params[:active])  if params[:active].present?
      items = items.where(for_sale: params[:for_sale])  if params[:for_sale].present?

      items.page(page)
    end
end
