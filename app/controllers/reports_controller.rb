# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ReportsController < ApplicationController
  before_filter :set_date_range, :set_tag_ids

  def index
    @report = Report.new(@date_range)
  end

  def present_date_range
    "del <i>#{I18n.l(date_range.date_start)}</i> al <i>#{I18n.l(date_range.date_end)}</i>".html_safe
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

  def set_tag_ids
    @tag_ids = Tag.select("id").where(id: params[:tags]).pluck(:id).uniq
  end
end
