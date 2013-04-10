require 'spec_helper'

describe DateRange do
  it "default" do
    dr = DateRange.default
    de = Date.today
    ds = de - 30.days 

    dr.should be_is_a(DateRange)
    dr.date_start.to_s.should eq(ds.to_s)
    dr.date_end.to_s.should eq(de.to_s)
  end

  it "range" do
    dr = DateRange.range('2013-01-01', '2013-03-01')
    dr.date_start.should eq(Date.parse('2013-01-01'))
    dr.date_end.should eq(Date.parse('2013-03-01'))
  end
end
