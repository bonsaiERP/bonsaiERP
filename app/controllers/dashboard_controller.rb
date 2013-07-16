# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  before_filter :set_date_range

  # GET /dashboard
  def index
    @dashboard = DashboardPresenter.new(view_context, @date_range)
  end

private
  def set_date_range
    @date_range = begin
      if dates_present?
        DateRange.parse(params[:date_start], params[:date_end])
      else
       DateRange.default
      end
    end
  end

  def dates_present?
    params[:date_start].present? && params[:date_end].present?
  end
end
