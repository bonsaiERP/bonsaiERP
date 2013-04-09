class DateRange < Struct.new(:start_date, :end_date)
  alias :sdate :start_date
  alias :edate :end_date

  def self.default
    last
  end

  def self.last(days = 30)
    d = Date.today
    new(d - days.days, d)
  end

  def self.range(s, e)
    s, e = (s.is_a?(String) ? Date.parse(s) : s), (e.is_a?(String) ? Date.parse(e) : e)
    new(s, e)
  end
end

