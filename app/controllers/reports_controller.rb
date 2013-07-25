# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ReportsController < ApplicationController
  include Controllers::DateRange

  before_filter :set_date_range, :set_tag_ids

  def index
    @report = Report.new(@date_range, tag_ids: @tag_ids)
  end

  def present_date_range
    "del <i>#{I18n.l(date_range.date_start)}</i> al <i>#{I18n.l(date_range.date_end)}</i>".html_safe
  end

private
  def set_tag_ids
    @tag_ids = Tag.select("id").where(id: params[:tags]).pluck(:id).uniq
  end
end
