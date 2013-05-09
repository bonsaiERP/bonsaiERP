# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  # GET /dashboard
  def index
    @dashboard = DashboardPresenter.new(view_context, date_range)
  end

private
  def date_range
    if params[:date_start].present? && dr = DateRange.parse(params[:date_start], params[:date_end])
      dr
    else
      flash.now[:error] = 'Los rangos de fecha son incorrectos.' if params[:date_start]
      DateRange.default
    end
  end
end
