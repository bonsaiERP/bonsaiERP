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
  it { should have_many(:inventory_details) }

  # Attachments relationships
  it { should have_one(:image).order('attachments.position').conditions(image: true).class_name('Attachment') }
  it { should have_many(:images).order('attachments.position').conditions(image: true).class_name('Attachment') }
  it { should have_many(:attachments).order('attachments.position').dependent(:destroy) }

  #it { should validate_uniqueness_of(:name) }
  it { should have_valid(:price).when(1, 0.1) }
  it { should_not have_valid(:price).when(-1, -0.1) }
  it { should have_valid(:buy_price).when(0, 1, 0.1,-0.0) }
  it { should_not have_valid(:buy_price).when(-1, -0.1) }

  let(:unit){ create :unit }
  let(:valid_attributes) do
    { name: 'First item', unit_id: unit.id, code: 'AU101',
      price: 12.0, for_sale: true, buy_price: 0, stockable: true
    }
  end

  let(:user) { build :user, id: 1 }

  before(:each) { UserSession.user = user }

  it "#valid_price" do
    i = Item.new(valid_attributes)
    expect(i.valid?).to eq(true)
    i.should be_for_sale
    i.price = - 1.0

    expect(i.valid?).to eq(false)
    expect(i.errors[:price].present?).to eq(true)
  end

  it "#to_s" do
    i = Item.new(name: 'Item name', code: '')
    i.to_s.should eq('Item name')

    i.code = '12323'
    i.to_s.should eq('Item name')
  end

  it "uniqueness_of_code" do
    i = Item.create!(valid_attributes)
    expect(i.persisted?).to eq(true)

    i = Item.new(valid_attributes)
    expect(i.valid?).to eq(false)
    expect(i.errors[:code].present?).to eq(true)
    expect(i.errors[:code]).to eq([I18n.t('activerecord.errors.models.item.attributes.code.taken')])

    # Name
    i = Item.new(valid_attributes.merge(code: ''))
    i.should_not be_valid
    expect(i.errors[:name]).to eq([I18n.t('activerecord.errors.models.item.attributes.name.taken')])

    # Code
    i = Item.new(valid_attributes.merge(code: '', name: 'Another name'))
    expect(i.valid?).to eq(true)
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
  end

  describe "Tests" do
    before(:each) do
      o = Object.new
      o.stub(:find_by_id).with(1).and_return(Unit.new)
      Unit.stub(org: o)
    end

    it 'should create an item' do
      Item.create!(valid_attributes)
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
      subject.destroy.destroyed?.should eq(true)
    end

    it "does not destroy the item" do
      MovementDetail.stub(:where).with(item_id: subject.id).and_return([1])
      subject.destroy.should eq(false)
    end

    it "does not destroy the item" do
      InventoryDetail.stub(:where).with(item_id: subject.id).and_return([1])
      subject.destroy.should eq(false)
    end
  end

  context "set_unit" do
    let(:unit2) { create :unit, symbol: 'un.', name: 'unidad' }

    it "sets the name" do
      i = Item.create!(valid_attributes.merge(unit_id: unit2.id))
      i.unit_name.should eq(unit2.name)
      i.unit_symbol.should eq(unit2.symbol)
      i.attributes["unit_name"].should eq(unit2.name)
      i.attributes["unit_symbol"].should eq(unit2.symbol)

      i = Item.find i.id

      i.update_attributes!(name: 'Sojooj', unit_id: unit.id)
      i.unit_name.should eq(unit.name)
      i.unit_symbol.should eq(unit.symbol)
    end
  end

  context 'scopes' do
    it "::search" do
      expect(Item.search('ba').to_sql).to match(
        /items.name ILIKE '%ba%' OR items.code ILIKE '%ba%'/)
    end

    it "::active" do
      expect(Item.active.to_sql).to match(/"items"."active" = 't'/)
    end

    it "::income" do
      expect(Item.income.to_sql).to match(/"items"."active" = 't' AND "items"."for_sale" = 't'/)
    end

    it "::for_sale" do
      expect(Item.income.to_sql).to match(/"items"."for_sale" = 't'/)
    end
  end

end
