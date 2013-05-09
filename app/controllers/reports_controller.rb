# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ReportsController < ApplicationController
  def index
    @report = ReportPresenter.new(view_context)

    case params[:report]
    when 'income', 'expense'
    when 'totals'
      render :totals
    when 'items'
      render 'items_trans'
    end
  end

private

end
