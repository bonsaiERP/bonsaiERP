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
    exp = Income.new_income(
      attributes_for(:income_approved).merge(
        contact_id: 3, balance_inventory: 100,
        income_details_attributes: [
          {item_id: 1, quantity: 5, price: 10, balance: 5},
          {item_id: 2, quantity: 5, price: 10, balance: 5}
        ]
      )
    )
    exp.save
    exp
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
    exp = Income.new_income(
      attributes_for(:income_approved).merge(
        contact_id: 3, balance_inventory: 100,
        income_details_attributes: [
          {item_id: 1, quantity: 5, price: 10, balance: 5},
          {item_id: 2, quantity: 5, price: 10, balance: 5}
        ]
      )
    )
    exp.save
    exp
  }

  it "#create" do
    Stock.any_instance.stub(item: item, store: store)

    invout = Incomes::InventoryIn.new(valid_attributes)
    invout.details.should have(2).items

    invout.create.should be_true
    inv = Inventory.find(invout.inventory.id)
    inv.should be_is_a(Inventory)
    inv.should be_is_inc_in
    inv.creator_id.should eq(user.id)
    inv.ref_number.should =~ /\AI-\d{2}-\d{4}\z/

    exp = Income.find(income.id)
    exp.balance_inventory.should == 60
    exp.details[0].balance.should == 3
    exp.details[1].balance.should == 3

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

    invout = Incomes::InventoryIn.new(attrs)
    invout.create.should be_true

    exp = Income.find(income.id)
    exp.balance_inventory.should == 0
    exp.details[0].balance.should == 0
    exp.details[1].balance.should == 0

    io = Inventory.find(invout.inventory.id)
    io.inventory_details.should have(2).items
    io.inventory_details.map(&:quantity).should eq([3, 3])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([5, 5])

    # Error
    invout = Incomes::InventoryIn.new(valid_attributes)
    invout.create.should be_false
    invout.details[0].errors[:quantity].should_not be_blank
    invout.details[1].errors[:quantity].should_not be_blank
  end
end
