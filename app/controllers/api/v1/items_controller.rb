class Api::V1::ItemsController < Api::V1::BaseController

  # GET /api/v1/items
  def index
    render json: Item.page(page).per(per).to_json
  end

  # GET /api/v1/items/count
  def show
    item = Item.find(params[:id])

    render json: item.to_json
  end

  # GET /api/v1/items/count
  def count
    render json: { count: Item.count }
  end


  private

    def items2
      ActiveRecord::Base.connection.select_rows(items_sql)
    end

    def items_sql
      <<-SQL
select row_to_json(row) from (select * from items) row;
      SQL
    end
end
