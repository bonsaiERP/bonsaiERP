# author: Boris Barroso
# email: boriscyber@gmail.com
class ReportsController < ApplicationController
  include Controllers::DateRange

  before_filter :set_date_range, :set_tag_ids

  def index
    @report = Report.new(@date_range, tag_ids: @tag_ids)
  end

  def inventory
    @report = InventoryReportService.new(inventory_params)
    @tag_group = TagGroup.api
  end


  def present_date_range
    "del <i>#{I18n.l(date_range.date_start)}</i> al <i>#{I18n.l(date_range.date_end)}</i>".html_safe
  end

  private

    def set_tag_ids
      @tag_ids = Tag.select("id").where(id: params[:tags]).pluck(:id).uniq
    end

    def inventory_params
      {
        type: params[:type] || 'Income',
        date_field: params[:date_field] || 'date',
        date_start: @date_range.date_start.to_s,
        date_end: @date_range.date_end.to_s,
        state: params[:state] || 'approved',
        tag_group_id: params[:tag_group_id]
      }
    end
end
