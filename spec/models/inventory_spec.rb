# encoding: utf-8
require 'spec_helper'

describe Inventory do
  it { should belong_to(:updater).class_name('User') }
  it { should belong_to(:store) }
  it { should belong_to(:store_to).class_name("Store") }
  it { should belong_to(:contact) }
  it { should belong_to(:creator) }
  it { should belong_to(:project) }
  it { should belong_to(:expense) }
  it { should belong_to(:income) }

  it { should have_many(:inventory_details) }
  it { should accept_nested_attributes_for(:inventory_details) }

  it { should validate_presence_of(:ref_number) }
  it { should validate_presence_of(:store) }
  it { should validate_presence_of(:store_id) }

  it { should have_valid(:operation).when(*Inventory::OPERATIONS) }
  it { should_not have_valid(:operation).when('je', '') }

  it '#set_ref_number' do
    Time.zone.stub(now: Time.zone.parse('2013-05-10'))
    inv_op = build :inventory, operation: 'in', ref_number: 'I-13-0001', id: 1

    io = Inventory.new(operation: 'in')
    io.set_ref_number
    io.ref_number.should eq('I-13-0001')

    Inventory.stub_chain(:select, :order, limit: [inv_op])
    io = Inventory.new(operation: 'in')
    io.set_ref_number
    io.ref_number.should eq('I-13-0002')

    Inventory.stub_chain(:select, :order, limit: [inv_op])
    io = Inventory.new(operation: 'in')
    io.set_ref_number
    io.ref_number.should eq('I-13-0002')

    inv_op.id = 2
    io = Inventory.new(operation: 'out')
    io.set_ref_number
    io.ref_number.should eq('E-13-0003')

    inv = Inventory.new(operation: 'inc_in')
    inv.set_ref_number
    inv.ref_number.should eq('I-13-0003')


    inv = Inventory.new(operation: 'exp_in')
    inv.set_ref_number
    inv.ref_number.should eq('I-13-0003')


    inv = Inventory.new(operation: 'inc_out')
    inv.set_ref_number
    inv.ref_number.should eq('E-13-0003')


    inv = Inventory.new(operation: 'exp_out')
    inv.set_ref_number
    inv.ref_number.should eq('E-13-0003')
  end

  it "#set_re_number trans" do
    Time.zone.stub(now: Time.zone.parse('2013-05-10'))
    i = Inventory.new(operation: 'trans')
    i.set_ref_number
    i.ref_number.should eq('T-13-0001')
  end

  it "creates methods for OPERATIONS" do
    inv = Inventory.new
    Inventory::OPERATIONS.each do |op|
      inv.operation = op
      inv.should send(:"be_is_#{op}")
    end
  end

  it "sets user_id" do
    UserSession.user = build(:user, id: 20)
    io = Inventory.new(operation: 'in', ref_number: '123', store_id: 1, date: Date.today)
    io.stub(store: build(:store))
    io.save.should eq(true)

    io.creator_id.should eq(20)
  end

  it "#is_trans?" do
    i = Inventory.new(operation: 'trans')
    i.should be_is_trans

    i.should_not be_is_in
    i.should_not be_is_out
  end

  it "#details alias" do
    inv = Inventory.new
    inv.inventory_details.build
    inv.inventory_details.should eq(inv.details)
  end
end
