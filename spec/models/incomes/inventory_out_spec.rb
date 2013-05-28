# encoding: utf-8
require 'spec_helper'

describe Incomes::InventoryOut do
  let(:store) { build :store, id: 1 }
  let(:item) { build :item, for_sale: true }
  let(:store) { build :store }
  let(:user) { build :user, id: 10 }


  before(:each) do

  end

  let(:contact) {
    cont = build :contact
    cont.stub(save: true)
    cont
  }

  let(:valid_attributes) {
    {store_id: 1, date: Date.today, description: 'Test inventory out', 
     income_id: income.id,
     inventory_details_attributes: [
       {item_id: 1, quantity: 2},
       {item_id: 2, quantity: 2}
    ]
    }
  }

  context 'create' do
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

    def create_inventory_in
      inv = Inventories::In.new(valid_attributes.merge({
        inventory_details_attributes: [
          {item_id: 1, quantity: 5},
          {item_id: 2, quantity: 4}
        ]
      }))
      inv.create
    end

    it "#create" do
      Stock.any_instance.stub(item: item, store: store)
      # Create with the function
      create_inventory_in.should be_true
      
      # Create

      invout = Incomes::InventoryOut.new(valid_attributes)
      invout.details.should have(2).items

      invout.create.should be_true
      inv = Inventory.find(invout.inventory.id)
      inv.should be_is_a(Inventory)
      inv.should be_is_inc_out
      inv.creator_id.should eq(user.id)
      inv.ref_number.should =~ /\AS-\d{2}-\d{4}\z/

      inc = Income.find(income.id)
      inc.balance_inventory.should == 60
      inc.details[0].balance.should == 3
      inc.details[1].balance.should == 3

      inv.details.should have(2).items
      inv.details.map(&:quantity).should eq([2, 2])
      inv.details.map(&:item_id).should eq([1, 2])

      stocks = Stock.active.where(store_id: inv.store_id)
      stocks.should have(2).items
      stocks.map(&:item_id).sort.should eq([1, 2])
      stocks.map(&:quantity).should eq([3, 2])

      # More items
      attrs = valid_attributes
      attrs[:inventory_details_attributes][0][:quantity] = 3
      attrs[:inventory_details_attributes][1][:quantity] = 3

      invout = Incomes::InventoryOut.new(attrs)
      invout.create.should be_true

      inc = Income.find(income.id)
      inc.balance_inventory.should == 0
      inc.details[0].balance.should == 0
      inc.details[1].balance.should == 0

      io = Inventory.find(invout.inventory.id)
      io.should be_has_error
      io.error_messages["quantity"].should eq(['inventory.negative_stock'])
      io.error_messages["item_ids"].should eq([2])

      io.inventory_details.should have(2).items
      io.inventory_details.map(&:quantity).should eq([3, 3])
      io.inventory_details.map(&:item_id).should eq([1, 2])

      stocks = Stock.active.where(store_id: io.store_id)
      stocks.should have(2).items
      stocks.map(&:item_id).sort.should eq([1, 2])
      stocks.map(&:quantity).should eq([0, -1])

      # Error
      invout = Incomes::InventoryOut.new(valid_attributes)
      invout.create.should be_false
      invout.details[0].errors[:quantity].should eq([I18n.t('errors.messages.inventory.movement_quantity')])
      invout.details[1].errors[:quantity].should_not be_blank


      # Error
      invout = Incomes::InventoryOut.new(valid_attributes.merge(
        inventory_details: [{item_id: 100, quantity: 1}]
      ))

      invout.create.should be_false
      invout.errors[:base].should_not be_blank
    end
  end
end
