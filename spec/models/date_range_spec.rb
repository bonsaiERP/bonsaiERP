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

  it "$range" do
    dr = DateRange.range('2013-01-01', '2013-03-01')
    dr.date_start.should eq(Date.parse('2013-01-01'))
    dr.date_end.should eq(Date.parse('2013-03-01'))

    dr.range.should eq(dr.date_start..dr.date_end)
  end

  context '$parse' do
    it "$parse" do
      dr = DateRange.parse('2013-01-01', '2013-03-02')
      dr.should be_is_a(DateRange)
    end

    it "returns false" do
      d = Date.today
      dr = DateRange.parse('2013-04-01', '2013-03-02')
      expect( dr.date_start ).to eq(d - 30.days)
      expect( dr.date_end ).to eq(d)
    end

    it "returns false" do
      d = Date.today
      dr = DateRange.parse('2013-04-01', '')
      expect( dr.date_start ).to eq(d - 30.days)
      expect( dr.date_end ).to eq(d)
    end
  end

  it "#valid?" do
    dr = DateRange.new(Date.today, Date.today)
    dr.should be_valid

    dr = DateRange.new(Date.today, '')
    dr.should_not be_valid

    dr = DateRange.new('', '')
    dr.should_not be_valid

    dr = DateRange.new(Date.today, '')
    dr.should_not be_valid

    dr = DateRange.new(Date.parse('2013-05-02'), Date.parse('2013-05-01'))
    dr.should_not be_valid
  end
end
