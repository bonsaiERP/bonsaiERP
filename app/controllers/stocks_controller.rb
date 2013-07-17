# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StocksController < ApplicationController
  # PUT /stocks/:id
  def update
    @stock = Stock.find(params[:id])

    if @stock.save_minimum(params[:minimum])
      render json: {success: true, id: params[:id], minimum: @stock.minimum}
    else
      render json: {success: false, id: params[:id]}
    end
  end

end
