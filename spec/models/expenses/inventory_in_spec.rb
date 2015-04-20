# encoding: utf-8
require 'spec_helper'

describe Expenses::InventoryIn do
  let(:store) { build :store, id: 1 }

  let(:contact) {
    cont = build :contact
    cont.stub(save: true)
    cont
  }

  before(:each) do
    ExpenseDetail.any_instance.stub(item: build(:item))
    Expense.any_instance.stub(contact: contact, set_supplier_and_expenses_status: true)
  end

  let(:expense) {
    exp = Expense.new(
      attributes_for(:expense_approved).merge(
        contact_id: 3, balance_inventory: 100,
        due_date: Date.today,
        expense_details_attributes: [
          {item_id: 1, quantity: 5, price: 10, balance: 5},
          {item_id: 2, quantity: 5, price: 10, balance: 5}
        ]
      )
    )
    exp.stub(contact: contact)
    exp.save
    exp
  }

  let(:valid_attributes) {
    {store_id: 1, date: Date.today, description: 'Test inventory in',
     expense_id: expense.id,
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

  it "#build_details" do
    invin = Expenses::InventoryIn.new(store_id: store.id, expense_id: expense.id)
    invin.build_details

    invin.inventory_details[0].item_id.should eq(1)
    invin.inventory_details[0].quantity.should eq(5)

    invin.inventory_details[1].item_id.should eq(2)
    invin.inventory_details[1].quantity.should eq(5)

    # Other quantities
    det = expense.expense_details[0]
    det.balance = 1
    det.save.should eq(true)

    invin = Expenses::InventoryIn.new(store_id: store.id, expense_id: expense.id)
    invin.build_details

    invin.inventory_details[0].item_id.should eq(1)
    invin.inventory_details[0].quantity.should eq(1)

    invin.inventory_details[1].item_id.should eq(2)
    invin.inventory_details[1].quantity.should eq(5)
  end

  it "#delivers" do
    InventoryDetail.any_instance.stub(item: item)
    Inventory.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)

    invin = Expenses::InventoryIn.new(valid_attributes)
    invin.details.size.should eq(2)

    invin.create.should eq(true)
    inv = Inventory.find(invin.inventory.id)
    inv.should be_is_a(Inventory)
    inv.should be_is_exp_in
    expect(inv.account_id).to be(expense.id)
    inv.creator_id.should eq(user.id)
    inv.ref_number.should =~ /\AI-\d{2}-\d{4}\z/

    exp = Expense.find(expense.id)
    exp.balance_inventory.should == 60
    exp.operation_type.should eq('inventory_in')

    exp.details[0].balance.should == 3
    exp.details[1].balance.should == 3

    inv.details.size.should eq(2)
    inv.details.map(&:quantity).should eq([2, 2])
    inv.details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: inv.store_id)
    stocks.size.should eq(2)
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([2, 2])

    # More items
    attrs = valid_attributes
    attrs[:inventory_details_attributes][0][:quantity] = 3
    attrs[:inventory_details_attributes][1][:quantity] = 3

    invin = Expenses::InventoryIn.new(attrs)
    invin.create.should eq(true)

    exp = Expense.find(expense.id)
    exp.balance_inventory.should == 0
    exp.details[0].balance.should == 0
    exp.details[1].balance.should == 0

    io = Inventory.find(invin.inventory.id)
    io.account_id.should be(expense.id)
    io.contact_id.should be(expense.contact_id)
    io.inventory_details.size.should eq(2)
    io.inventory_details.map(&:quantity).should eq([3, 3])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.size.should eq(2)
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([5, 5])

    # Error
    invin = Expenses::InventoryIn.new(valid_attributes)
    invin.create.should eq(false)
    invin.details[0].errors[:quantity].should_not be_blank
    invin.details[1].errors[:quantity].should_not be_blank
  end
end
