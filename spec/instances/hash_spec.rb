# encoding: utf-8
require 'spec_helper'
Hash.send(:include, HashExt)

describe Hash do
  before(:each) do
    @h = {"date(1i)" => "2011", "date(2i)" => "12", "date(3i)" => "10"}
  end
  
  it 'should return correct values for a hash' do
    @h.transform_date_parameters!("date")
    @h.should == {"date" => "2011-12-10"}
  end

  it 'should create for datetime' do
    h = {"fec(1i)" => "2011", "fec(2i)" => "12", "fec(3i)" => "10", "fec(6i)" => "6", "fec(4i)" => "4", "fec(5i)" => "5"}.merge(@h)

    h.transform_date_parameters!("fec", "date")

    h["date"].should == "2011-12-10"
    h["fec"].should == "2011-12-10 4:5:6"
  end

  it 'should transforn and symbolize' do
    h = {"fec(1i)" => "2011", "fec(2i)" => "12", "fec(3i)" => "10", "fec(6i)" => "6", "fec(4i)" => "4", "fec(5i)" => "5"}.merge(@h)

    h.transform_time_and_symbolize!("fec", "date")

    h[:date].should == "2011-12-10"
    h[:fec].should == "2011-12-10 4:5:6"
  end

  it 'should not change if there is no data' do
    h = {:ini => 1}
    h.transform_time_and_symbolize!("date")

    h.should == {:ini => 1}
  end
end
