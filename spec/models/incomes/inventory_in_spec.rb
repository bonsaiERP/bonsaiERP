# encoding: utf-8
require 'spec_helper'

describe Incomes::InventoryIn do
  let(:store) { build :store, id: 1 }

  let(:contact) {
    cont = build :contact
    cont.stub(save: true)
    cont
  }

  let(:income) {
    inc = Income.new(
      attributes_for(:income_approved).merge(
        contact_id: 3, balance_inventory: 100, due_date: Date.today,
        income_details_attributes: [
          {item_id: 1, quantity: 5, price: 10, balance: 5},
          {item_id: 2, quantity: 5, price: 10, balance: 5}
        ]
      )
    )
    inc.save
    inc
  }

  let(:valid_attributes) {
    {store_id: 1, date: Date.today, description: 'Test inventory in',
     income_id: income.id,
     inventory_details_attributes: [
       {item_id: 1, quantity: 2},
       {item_id: 2, quantity: 2}
    ]
    }
  }
  let(:item) { build :item }
  let(:store) { build :store }
  let(:user) { build :user, id: 10 }

  before(:each) do
    UserSession.user = user
    Income.any_instance.stub(contact: contact, set_client_and_incomes_status: true)
    Store.stub_chain(:active, where: [store])
    IncomeDetail.any_instance.stub(item: item)
    InventoryDetail.any_instance.stub(item: item)
    Inventory.any_instance.stub(store: store)
  end

  let(:income) {
    exp = Income.new(
      attributes_for(:income_approved).merge(
        contact_id: 3, balance_inventory: 0, due_date: Date.today,
        income_details_attributes: [
          {item_id: 1, quantity: 5, price: 10, balance: 0},
          {item_id: 2, quantity: 5, price: 10, balance: 0}
        ]
      )
    )
    exp.save
    exp
  }

  it "#initializes" do
    invin = Incomes::InventoryIn.new(income_id: income.id)
    invin.build_details
    invin.details[0].quantity.should == 0
    expect(invin.details[0].item_id).to eq(1)
    invin.details[1].quantity.should == 0
    expect(invin.details[1].item_id).to eq(2)
  end

  it "#create" do
    Stock.any_instance.stub(item: item, store: store)

    invin = Incomes::InventoryIn.new(valid_attributes)
    invin.details.should have(2).items
    expect(invin.income_id).to eq(income.id)

    invin.create.should be_true
    inv = Inventory.find(invin.inventory.id)
    inv.should be_is_a(Inventory)
    inv.should be_is_inc_in
    expect(inv.account_id).to eq(income.id)
    inv.creator_id.should eq(user.id)
    inv.ref_number.should =~ /\AI-\d{2}-\d{4}\z/

    inc = Income.find(income.id)
    inc.balance_inventory.should == 40
    inc.operation_type.should eq('inventory_in')

    inc.details[0].balance.should == 2
    inc.details[1].balance.should == 2

    inv.details.should have(2).items
    inv.details.map(&:quantity).should eq([2, 2])
    inv.details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: inv.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([2, 2])

    # More items
    attrs = valid_attributes
    attrs[:inventory_details_attributes][0][:quantity] = 3
    attrs[:inventory_details_attributes][1][:quantity] = 3

    invin = Incomes::InventoryIn.new(attrs)
    invin.create.should be_true

    inc = Income.find(income.id)
    inc.balance_inventory.should == 100
    inc.details[0].balance.should == 5
    inc.details[1].balance.should == 5

    io = Inventory.find(invin.inventory.id)
    io.inventory_details.should have(2).items
    io.inventory_details.map(&:quantity).should eq([3, 3])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([5, 5])

    # Error
    invin = Incomes::InventoryIn.new(valid_attributes)
    invin.create.should be_false
    invin.details[0].errors[:quantity].should_not be_blank
    invin.details[1].errors[:quantity].should_not be_blank
  end
end
