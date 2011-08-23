# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StocksController < ApplicationController
  def new
    @stock = Stock.new_item(params)
    unless @stock
      render :text => 'Error'
    end
  end

  def create
    @stock = Stock.new_item(params[:stock])

    if @stock and @stock.save
      redirect_ajax @stock
    else
      render "new"
    end
  end

end
