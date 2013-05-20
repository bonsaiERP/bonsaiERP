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

  it '#set_ref_number' do
    Date.stub(today: Date.parse('2013-05-10'))
    inv_op = build :inventory_operation, operation: 'in', ref_number: 'I-13-0001', id: 1

    io = InventoryOperation.new(operation: 'in')
    io.set_ref_number
    io.ref_number.should eq('I-13-0001')

    InventoryOperation.stub_chain(:select, :order, limit: [inv_op])
    io = InventoryOperation.new(operation: 'in')
    io.set_ref_number
    io.ref_number.should eq('I-13-0002')

    InventoryOperation.stub_chain(:select, :order, limit: [inv_op])
    io = InventoryOperation.new(operation: 'in')
    io.set_ref_number
    io.ref_number.should eq('I-13-0002')

    inv_op.id = 2
    io = InventoryOperation.new(operation: 'out')
    io.set_ref_number
    io.ref_number.should eq('S-13-0003')
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
    io = InventoryOperation.new(operation: 'in', ref_number: '123', store_id: 1, date: Date.today)
    io.stub(store: Object.new)
    io.save.should be_true

    io.creator_id.should eq(20)
  end

  it "#is_in?" do
    io = InventoryOperation.new
    InventoryOperation::IN_OPERATIONS.each do |op|
      io.operation = op
      io.should be_is_in
    end
  end

  it "#is_out?" do
    io = InventoryOperation.new
    InventoryOperation::OUT_OPERATIONS.each do |op|
      io.operation = op
      io.should be_is_out
    end
  end
end
