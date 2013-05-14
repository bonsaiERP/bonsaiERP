# encoding: utf-8
require 'spec_helper'

describe InventoryIncomeIn do
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
     inventory_operation_details_attributes: [
       {item_id: 1, quantity: 2},
       {item_id: 2, quantity: 2}
    ]
    }
  }
  let(:item) { build :item }
  let(:store) { build :store }
  let(:user) { build :user, id: 10 }

  it "#initialize" do
    invin = InventoryIncomeIn.new

    invin.inventory_operation.should be_is_incin
  end

  before(:each) do
    UserSession.user = user
  end

  it "creates" do
    InventoryOperationDetail.any_instance.stub(item: item)
    InventoryOperation.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)

    invin = InventoryIncomeIn.new(valid_attributes)
    invin.inventory_operation_details.should have(2).items

    invin.deliver.should be_true
true.should be_false
    io = InventoryOperation.find(invin.inventory_operation.id)
    io.should be_is_a(InventoryOperation)
    io.should be_is_invin
    io.creator_id.should eq(user.id)
    io.ref_number.should =~ /\AIng-\d{2}-\d{4}\z/

=begin
    io.inventory_operation_details.should have(2).items
    io.inventory_operation_details.map(&:quantity).should eq([2, 2])
    io.inventory_operation_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([2, 2])

    # More items
    attrs = valid_attributes.merge(inventory_operation_details_attributes:
      [{item_id: 2, quantity: 2, store_id: 1},
       {item_id: 12, quantity: 5, store_id: 1},
       {item_id: 2, quantity: 10, store_id: 1}
      ]
    )
    invin = InventoryIncomeIn.new(attrs)
    invin.create.should be_true
    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(3).items

    stocks.find {|v| v.item_id === 2}.quantity.should == 14
    stocks.find {|v| v.item_id === 12}.quantity.should == 5
    stocks.find {|v| v.item_id === 1}.quantity.should == 2
=end
  end
end

