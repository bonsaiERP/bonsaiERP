class MovementDetailsHistoryController < ApplicationController

  # GET /movement_details_history
  def show
    @history = present History.find(params[:id]), MovementHistoryDetailsPresenter
  end
end
