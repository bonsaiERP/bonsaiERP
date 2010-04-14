require 'spec_helper'

describe Country do
  before(:each) do
    @params = {:name => "Bolivia", :abbreviation => "bo"}
  end

  it 'should create a valid' do
    Country.create!(@params)
  end

  it 'should show name as to_s method' do
    @c = Country.create!(@params)
    @c.to_s.should == @c.name
  end
end
