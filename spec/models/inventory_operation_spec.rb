# encoding: utf-8
require 'spec_helper'

describe InventoryOperation do
  it { should belong_to(:store) }
  it { should belong_to(:contact) }
  it { should belong_to(:creator) }
  it { should belong_to(:project) }

  it { should have_many(:inventory_operation_details) }
  it { should accept_nested_attributes_for(:inventory_operation_details) }

  it { should validate_presence_of(:ref_number) }
  it { should validate_presence_of(:store) }
  it { should validate_presence_of(:store_id) }

  it { should have_valid(:operation).when(*InventoryOperation::OPERATIONS) }
  it { should_not have_valid(:operation).when('je', '') }

  it '::get_ref_number' do
    Date.stub(today: Date.parse('2013-05-10'))
    InventoryOperation.get_ref_number('Ing').should eq('Ing-13-0001')

    InventoryOperation.stub_chain(:order, limit: stub(pluck: ['Ing-13-0003']))
    InventoryOperation.get_ref_number('Ing').should eq('Ing-13-0004')

    InventoryOperation.stub_chain(:order, limit: stub(pluck: ['Ing-13-12345']))
    InventoryOperation.get_ref_number('Ing').should eq('Ing-13-12346')

    Date.stub(today: Date.parse('2014-01-01'))
    InventoryOperation.get_ref_number('Ing').should eq('Ing-14-0001')
  end

  it "creates methods for OPERATIONS" do
    inv = InventoryOperation.new
    InventoryOperation::OPERATIONS.each do |op|
      inv.operation = op
      inv.should send(:"be_is_#{op}")
    end
  end

  it "sets user_id" do
    UserSession.user = build(:user, id: 20)
    io = InventoryOperation.new(operation: 'invin', ref_number: '123', store_id: 1)
    io.stub(store: Object.new)
    io.save.should be_true 

    io.creator_id.should eq(20)
  end
end
