# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StocksController < ApplicationController
  def edit
    @stock = Stock.new_minimum(params[:item_id], params[:store_id])
    unless @stock
      render :text => 'Error'
    end
  end

  def update
    @stock = Stock.org.find(params[:id])

    if @stock.save_minimum(params[:stock][:minimum])
      render "update"
    else
      render "edit"
    end
  end

end
