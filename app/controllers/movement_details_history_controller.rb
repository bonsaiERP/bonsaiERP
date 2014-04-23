class MovementDetailsHistoryController < ApplicationController

  # GET /movement_details_history
  def show
    @history = History.find(params[:id])
  end
end
