#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Unit do

  let(:params) {
    {:name => "kilogram", :symbol => "kg", :integer => false}
  }

  before(:each) do
    UserSession.user = build :user, id: 10
  end


  it 'should create an instance' do
    Unit.create!(params)
  end

  it 'should validate uniqueness' do
    u = Unit.create!(params)
    u = Unit.new(params)
    u.should_not be_valid
    u.errors[:name].should_not be_blank
    u.errors[:symbol].should_not be_blank
  end

  it 'should create many units' do
    Unit.count.should == 0
    Unit.create_base_data
    Unit.count.should > 0
  end

  context "#update_item_units" do
    let(:unit) { create :unit, name: 'Unidad 1' }
    let(:item) { create :item, unit_id: unit.id }

    it "updates" do
      u = Unit.find(unit.id)
      u.name = 'A new fresh name'
      u.save.should eq(true)

      i = Item.find(item.id)
      i.unit_name.should eq('A new fresh name')
      i.unit_symbol.should eq(unit.symbol)

      u.symbol = 'ggHrt'
      u.save

      i = Item.find(item.id)
      i.unit_name.should eq('A new fresh name')
      i.unit_symbol.should eq('ggHrt')
    end
  end

  context '::scopes' do
    subject { Unit }

    it "invisible" do
      expect(subject.invisible.to_sql).to match(/"units"."visible" = 'f'/)
    end
  end
end
