# encoding: utf-8
require 'spec_helper'

describe Expenses::InventoryOut do
  let(:store) { build :store, id: 1 }

  before(:each) do
    IncomeDetail.any_instance.stub(item: true, item_for_sale?: true)
  end
  let(:contact) {
    cont = build :contact
    cont.stub(save: true)
    cont
  }

  let(:income) {
    inc = Income.new_income(
      attributes_for(:income_approved).merge(
        contact_id: 3,
        income_details_attributes: [
          {item_id: 1, quantity: 5, price: 10},
          {item_id: 2, quantity: 5, price: 10}
        ]
      )
    )
    inc.stub(contact: contact)
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
    Income.any_instance.stub(contact: contact)
    Store.stub_chain(:active, where: [store])
  end

  it "#delivers" do
    InventoryDetail.any_instance.stub(item: item)
    Inventory.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)

    invout = Expenses::InventoryOut.new(valid_attributes)
    invout.details.should have(2).items

    invout.save.should be_true

    io = InventoryOperation.find(invin.inventory_operation.id)
    io.should be_is_a(InventoryOperation)
    io.should be_is_invincin
    io.creator_id.should eq(user.id)
    io.ref_number.should =~ /\AIngI-\d{2}-\d{4}\z/

    inc = Income.find(income.id)
    inc.income_details[0].balance.should == 3
    inc.income_details[1].balance.should == 3

    io.inventory_operation_details.should have(2).items
    io.inventory_operation_details.map(&:quantity).should eq([2, 2])
    io.inventory_operation_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([-2, -2])

    # More items
    attrs = valid_attributes
    attrs[:inventory_operation_details_attributes][0][:quantity] = 3
    attrs[:inventory_operation_details_attributes][1][:quantity] = 3

    invin = Expenses::Inventory.new(attrs)
    invin.deliver.should be_true

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items

    inc = Income.find(income.id)
    inc.income_details[0].balance.should == 0
    inc.income_details[1].balance.should == 0

    io = InventoryOperation.find(invin.inventory_operation.id)
    io.inventory_operation_details.should have(2).items
    io.inventory_operation_details.map(&:quantity).should eq([3, 3])
    io.inventory_operation_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([-5, -5])

    # Error
    invin = Expenses::Inventory.new(valid_attributes)
    invin.deliver.should be_false
    invin.items[0].errors[:quantity].should_not be_blank
    invin.items[1].errors[:quantity].should_not be_blank
  end
end


