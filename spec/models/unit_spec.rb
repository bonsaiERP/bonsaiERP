#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Unit do

  before(:each) do
    @params = {:name => "kilogram", :symbol => "kg", :integer => false}
  end


  it 'should create an instance' do
    Unit.create!(@params)
  end

  it 'should validate uniqueness' do
    u = Unit.create!(@params)
    u = Unit.new(@params)

    u.should_not be_valid
    u.errors[:name].should_not be_blank
    u.errors[:symbol].should_not be_blank
  end

  it 'should create many units' do
    Unit.count.should == 0
    Unit.create_base_data
    Unit.count.should > 0
  end
end
