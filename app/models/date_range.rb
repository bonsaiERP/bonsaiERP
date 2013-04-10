class DateRange < Struct.new(:date_start, :date_end)
  alias :dates :date_end
  alias :dates :date_end

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

