# Module to add date_range in search
module Controllers::DateRange

private
  def set_date_range
    @date_range = begin
      if dates_present?
        ::DateRange.parse(params[:date_start], params[:date_end])
      else
       ::DateRange.default
      end
    end
  end

  def dates_present?
    params[:date_start].present? && params[:date_end].present?
  end
end
