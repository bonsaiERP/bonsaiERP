require 'spec_helper'

describe DateRange do
  it "default" do
    dr = DateRange.default
    de = Date.today
    ds = de - 30.days 

    dr.should be_is_a(DateRange)
    dr.start_date.to_s.should eq(ds.to_s)
    dr.end_date.to_s.should eq(de.to_s)
  end

  it "range" do
    dr = DateRange.range('2013-01-01', '2013-03-01')
    dr.start_date.should eq(Date.parse('2013-01-01'))
    dr.end_date.should eq(Date.parse('2013-03-01'))
  end
end
