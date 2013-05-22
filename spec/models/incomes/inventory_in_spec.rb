# encoding: utf-8
require 'spec_helper'

describe Incomes::InventoryIn do
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

  it "::new_out" do
    inv = Incomes::Inventory.new_out(valid_attributes.dup)
    inv.inventory.should be_is_out
    inv.inventory.should be_is_inc_out
    inv.inventory.ref_number.should =~ /S-\d{2}-\d{4}/
    inv.inventory.date.should eq(valid_attributes.fetch(:date))
    inv.inventory.description.should eq(valid_attributes.fetch(:description))
  end

  it "::new_in" do
    inv = Incomes::Inventory.new_in(valid_attributes.dup)
    inv.inventory.should be_is_in
    inv.inventory.should be_is_inc_in
    inv.inventory.ref_number.should =~ /I-\d{2}-\d{4}/
    inv.inventory.date.should eq(valid_attributes.fetch(:date))
    inv.inventory.description.should eq(valid_attributes.fetch(:description))
  end

  it "#save" do
    InventoryDetail.any_instance.stub(item: item)
    Inventory.any_instance.stub(store: store)
    Stock.any_instance.stub(item: item, store: store)

    attrs = valid_attributes.dup
    # inc_out
    inv = Incomes::Inventory.new_out(attrs)
    inv.inventory_details.should have(2).items

    inv.save.should be_true

    io = Inventory.find(inv.inventory.id)
    io.should be_is_a(Inventory)
    io.should be_is_inc_out
    io.creator_id.should eq(user.id)
    io.ref_number.should =~ /\AS-\d{2}-\d{4}\z/

    inc = Income.find(income.id)
    inc.income_details[0].balance.should == 3
    inc.income_details[1].balance.should == 3

    io.inventory_details.should have(2).items
    io.inventory_details.map(&:quantity).should eq([2, 2])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([-2, -2])

    # More items
    attrs = valid_attributes.dup
    attrs[:inventory_details_attributes][0][:quantity] = 3
    attrs[:inventory_details_attributes][1][:quantity] = 3

    inv = Incomes::Inventory.new_out(attrs)
    inv.save.should be_true

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items

    inc = Income.find(inv.income_id)
    inc.income_details[0].balance.should == 0
    inc.income_details[1].balance.should == 0

    io = InventoryOperation.find(inv.inventory.id)
    io.inventory_details.should have(2).items
    io.inventory_details.map(&:quantity).should eq([3, 3])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([-5, -5])

    # Error
    inv = Incomes::Inventory.new_out(valid_attributes.dup)
    inv.save.should be_false
    inv.details[0].errors[:quantity].should_not be_blank
    inv.details[1].errors[:quantity].should_not be_blank

    ##############################################
    # Devolution
    # inc_in
    attrs = valid_attributes.dup
    attrs[:inventory_details_attributes][0][:quantity] = 3
    attrs[:inventory_details_attributes][1][:quantity] = 3

    inv = Incomes::Inventory.new_in(attrs)
    inv.save.should be_true

    io = InventoryOperation.find(inv.inventory.id)

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items

    inc = Income.find(inv.income_id)
    inc.income_details[0].balance.should == 3
    inc.income_details[1].balance.should == 3

    io = InventoryOperation.find(inv.inventory.id)
    io.inventory_details.should have(2).items
    io.inventory_details.map(&:quantity).should eq([3, 3])
    io.inventory_details.map(&:item_id).should eq([1, 2])

    stocks = Stock.active.where(store_id: io.store_id)
    stocks.should have(2).items
    stocks.map(&:item_id).sort.should eq([1, 2])
    stocks.map(&:quantity).should eq([-2, -2])

    # ERROR
    inv = Incomes::Inventory.new_in(valid_attributes.merge(inventory_details_attributes: [
       {item_id: 1, quantity: 3},
       {item_id: 2, quantity: 3}
    ]))
    inv.save.should be_false
    inv.details.each do |it|
      it.errors[:quantity].should eq([I18n.t('errors.messages.inventory_detail.transaction_quantity')])
    end
  end
end

