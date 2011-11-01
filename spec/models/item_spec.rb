# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

describe Item do

  let(:valid_params) {
    { :name => 'First item', :unit_id => 1, :code => 'AU101', :price => 12, :ctype => "product" }
  }

  before(:each) do
    OrganisationSession.set = {:id => 1, :name => 'ecuanime'}
  end

  describe "Validatios" do
    before(:each) do
      Unit.stub!(:org => stub(:find_by_id => mock_model(Unit)) )
    end

    it { should have_valid(:price).when(0) }
    it { should_not have_valid(:price).when('a', 'b', nil) }

    it { should have_valid(:ctype).when(*Item::TYPES) }
    it { should_not have_valid(:ctype).when('other', 'items') }

    it { should have_valid(:unit_id).when(1) }
    it { should_not have_valid(:unit_id).when(nil) }
  end

  describe "Tests" do
    before(:each) do
      o = Object.new
      o.stub!(:find_by_id).with(1).and_return(mock_model(Unit))
      Unit.stub!(:org => o)
    end

    it 'should create an item' do
      i = Item.create!(valid_params)
    end

    it 'should not allow other unit_id' do
      i = Item.new( valid_params.dup.merge(:unit_id => 2) )

      expect{ i.valid?}.to raise_error
    end

    it 'should be a unique code' do
     Item.create valid_params 
     i = Item.new(valid_params)

     i.should_not be_valid
     i.errors[:code].should_not be_blank
    end
  end

end
