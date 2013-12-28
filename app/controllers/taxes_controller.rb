class TaxesController < ApplicationController
  def index

  end

  # GET /taxes/new
  def new
    @tax = Tax.new
  end

  # POST /taxes
  def create
    @tax = Tax.new tax_params

    if @tax.save
      if request.xhr?
        render json: { id: @tax.id, to_s: @tax.to_s, percentage: @tax.percentage, name: @tax.name }
      end
    else
      render :new
    end
  end

  private

    def tax_params
      params.require(:tax).permit(:name, :percentage)
    end
end
