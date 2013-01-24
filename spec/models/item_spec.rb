# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

describe Item do
  it { should belong_to(:unit) }
  it { should have_many(:stocks) }
  it { should have_many(:income_details) }
  it { should have_many(:expense_details) }
  it { should have_many(:inventory_operation_details) }

  let(:unit){ create :unit }
  let(:valid_attributes) do
    { name: 'First item', unit_id: unit.id, code: 'AU101',
      price: 12.0, for_sale: true, stockable: true
    }
  end

  it "creates an instance with default values" do
    item = Item.new
    item.should be_for_sale
    item.should be_stockable
    item.should be_active
    item.price.should == 0
  end

  describe "Validatios" do
    it { should have_valid(:unit_id).when(1) }
    it { should_not have_valid(:unit_id).when(nil) }

    it 'should not have valid unit_id' do
      i = Item.new(valid_attributes.merge(unit_id: unit.id + 1))
      i.should_not be_valid
    end

    it 'should be valid if not for sale' do
      i = Item.new(valid_attributes.merge(for_sale: false, price: ''))

      i.should be_valid
      
      i.for_sale = true
      i.should_not be_valid

      i.price = 'a'
      i.should_not be_valid
    end
  end

  describe "Tests" do
    before(:each) do
      o = Object.new
      o.stub!(:find_by_id).with(1).and_return(mock_model(Unit))
      Unit.stub!(org: o)
    end

    it 'should create an item' do
      i = Item.create!(valid_attributes)
    end

    it 'should be a unique code' do
     Item.create valid_attributes 
     i = Item.new(valid_attributes)

     i.should_not be_valid
     i.errors[:code].should_not be_blank
    end
  end

  describe "Destroy" do
    subject { Item.create valid_attributes }

    it "destroys the item" do
      subject.destroy.should be_true
    end

    it "does not destroy the item" do
      TransactionDetail.stub(:where).with(item_id: subject.id).and_return([1])
      subject.destroy.should be_false
    end

    it "does not destroy the item" do
      InventoryOperationDetail.stub(:where).with(item_id: subject.id).and_return([1])
      subject.destroy.should be_false
    end
  end
end
