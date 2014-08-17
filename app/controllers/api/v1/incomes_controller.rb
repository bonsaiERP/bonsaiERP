class Api::V1::IncomesController < Api::V1::BaseController

  # GET /api/v1/incomes
  def index
    render json: Income.page(page).per(per).to_json
  end

  # GET /api/v1/incomes/:id
  def show
    render json: Income.find(params[:id])
  end

  # POST /api/v1/incomes
  def create
    inc = Incomes::Form.new_income(income_params)
    if inc.create_and_approve
      render json: inc.income.to_json
    else
      render json: { errors: inc.errors }, status: 409
    end
  end

  # GET /api/v1/incomes/count
  def count
    render json: { count: Income.count }
  end

  private

    def income_params
      params.require(:income).permit(*movement_params.income)
    end

    def movement_params
      @movement_params ||= MovementParams.new
    end
end
