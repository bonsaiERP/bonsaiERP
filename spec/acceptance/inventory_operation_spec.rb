# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Inventory Operation", "Test IN/OUT" do
  background do

    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    Store.create!(:name => 'First store', :address => 'An address') {|s| s.id = 1 }
  end

  let(:item_service) { Item.org.service.first }

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }
  let!(:supplier) { create_supplier(:matchcode => 'Proveedor 1')}
  let!(:client) { create_client(:matchcode => 'Cliente 1')}
  let!(:bank) { create_bank(:number => '123', :amount => 0) }
  let(:bank_account) { bank.account }
  let!(:client) { create_client(:matchcode => 'Karina Luna') }
  let!(:tax) { Tax.create(:name => "Tax1", :abbreviation => "ta", :rate => 10)}
  let(:income_params) {
    d = Date.today
    i_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id" => client.id, 
      "exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount" => 0, "project_id"=>1 
    }
    details = [
      { "description"=>"jejeje", "item_id"=> 1, "price"=>3, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=> 2, "price"=>5, "quantity"=> 20}
    ]
    i_params[:transaction_details_attributes] = details
    i_params
  }

  scenario 'make an IN' do
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => client.id, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    io = InventoryOperation.new(hash)
    io.inventory_operation_details.size.should == 2
    io.save_operation.should be_true
    io.should be_persisted
    io.reload
    io.creator_id.should == UserSession.user_id

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 200

    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
    io.should be_persisted
    io.reload

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 200

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 400

  end

  scenario "create OUT" do

    # Create an IN to have inventory and not have validation errors
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    io = InventoryOperation.new(hash)
    io.inventory_operation_details.size.should == 2
    io.save_operation.should be_true
    io.should be_persisted

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 200

    # Create an OUT
    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 50},
        {:item_id =>2, :quantity => 100}
      ]
    }

    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
    io.should be_persisted

    io.reload

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 50

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 100

    # Try to make an out with a quantity greater than stock
    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 51},
        {:item_id =>2, :quantity => 100}
      ]
    }

    io = InventoryOperation.new(hash)
    io.save_operation.should be_false
    io.should_not be_persisted
    io.inventory_operation_details[0].errors[:quantity].should_not be_blank

  end

  scenario "make OUT for Income" do
    # Create inventory for the stock
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :store_id => 1, :operation => 'in',
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    
    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
    
    # Income
    i = Income.new(income_params)
    i.save_trans.should be_true
    i.approve!.should be_true

    i.balance.should == (3 * 10 + 5 * 20)
    i.deliver = true
    i.save.should be_true

    det = i.transaction_details[0]
    det.balance.should == det.quantity
    
    i.deliver = true
    i.save.should be_true
    i.should be_deliver

    # Create and OUT for Income
    hash = hash.merge(:transaction_id => i.id, :operation => 'out')

    io = InventoryOperation.new(hash)
    io.save_transaction.should be_false
    io.should_not be_persisted
    io.should be_out

    io.inventory_operation_details[0].errors.should_not == blank?
    io.inventory_operation_details[1].errors.should_not == blank?

    i.transaction_details[0].balance.should == i.transaction_details[0].quantity
    i.transaction_details[1].balance.should == i.transaction_details[1].quantity

    hash[:inventory_operation_details_attributes][0][:quantity] = 5
    hash[:inventory_operation_details_attributes][1][:quantity] = 10
    io = InventoryOperation.new(hash)

    io.save_transaction.should be_true
    io.should be_out
    io.should be_persisted

    iodet1 = io.inventory_operation_details[0]
    iodet2 = io.inventory_operation_details[1]

    i.reload
    dets = i.transaction_details(true)

    det1 = dets[0]
    det2 = dets[1]

    det1.balance.should == 5
    det1.delivered.should == det1.quantity - det1.balance

    iodet1.transaction_id.should == io.transaction_id
    iodet1.operation.should == io.operation
    iodet1.store_id.should == io.store_id
    iodet1.contact_id.should == io.contact_id

    det2.balance.should == 10
    det2.delivered.should == det2.quantity - det2.balance

    iodet2.transaction_id.should == io.transaction_id
    iodet2.operation.should == io.operation
    iodet2.store_id.should == io.store_id
    iodet2.contact_id.should == io.contact_id

    io.reload
    io.transaction.delivered.should be_false

    # IO operation for income
    h = hash.merge(
      :transaction_id => i.id, :operation => 'out',
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 5},
        {:item_id =>2, :quantity => 10}
      ]
    )

    io = InventoryOperation.new(h)
    io.save_transaction.should be_true
    io.should be_persisted
    io.reload

    io.transaction.delivered.should be_true

    i.transaction_details(true)
    i.transaction_details[0].balance.should == 0
    i.transaction_details[0].delivered.should == 10
    i.transaction_details[1].balance.should == 0
    i.transaction_details[1].delivered.should == 20

    # It should not allow another out for income
    h = hash.merge(
      :transaction_id => i.id, :operation => 'out',
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 5},
        {:item_id =>2, :quantity => 0}
      ]
    )

    io = InventoryOperation.new(h)
    io.save_transaction.should be_false
    io.should_not be_persisted
  end

  scenario "Make an OUT for income with some values with 0" do
    i = Income.new(income_params)
    i.save_trans.should == true
    i.approve!

    i.deliver = true
    i.save.should be_true

    det = i.transaction_details[0]
    det.balance.should == det.quantity
    
    # Create inventory
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    
    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
    io.should be_persisted

    io.store.stocks(true).unscoped.size.should == 2
    # Check the stocks
    stocks = Hash[ Store.find(1).stocks.map {|st| [st.item_id, st.quantity] } ]

    # Income with 0 quantity
    hash = hash.merge(:transaction_id => i.id, :operation => 'out')

    io = InventoryOperation.new(hash)
    io.inventory_operation_details[0].quantity = 0
    io.inventory_operation_details[1].quantity = 10

    io.save_transaction.should be_true
    io.should be_persisted

    io.store.stocks(true)
    io.store.stocks.find_by_item_id(1).quantity.should == stocks[1]
    io.store.stocks.find_by_item_id(2).quantity.should == stocks[2] - 10

    io.store.stocks.unscoped.size.should == 3
  end

  scenario "Make IN for a buy and make partial deliveries" do
    b = Buy.new(income_params)
    b.save_trans.should be_true
    b.approve!.should be_true

    b.discount.should == 0
    b.total_discount.should == 0
    b.total_taxes.should == 0

    hash = {:date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1, :transaction_id => b.id }
    io = InventoryOperation.new(hash)
    io.set_transaction
    io.should be_in

    io.inventory_operation_details.should have(2).elements
    io.ref_number.should_not be_blank
    # Set to 0
    io.inventory_operation_details[0].quantity = 0

    io.save_transaction.should be_true
    io.should be_persisted
    io.inventory_operation_details[1].quantity.should == b.transaction_details[1].balance

    b.reload
    b.transaction_details[0].balance.should == b.transaction_details[0].quantity
    b.transaction_details[1].balance.should == 0

    b.reload
    b.delivered.should be_false

    io = InventoryOperation.new(hash)
    io.set_transaction
    io.inventory_operation_details[0].quantity.should == b.transaction_details[0].balance
    # Try to enter greater than the amount
    io.inventory_operation_details[0].quantity = b.transaction_details[0].balance + 1

    io.save_transaction.should be_false
  end

  scenario "Make OUT for a service should not change inventory" do
    i_params = income_params.dup
    i_params[:transaction_details_attributes] << {"item_id" => 5, :quantity => 5, "price" => 10}
    i_params["discount"] = 0
    i = Income.new(i_params)

    i.transaction_details.last.item.should be_service
    i.save_trans.should be_true
    i.should be_persisted

    i.approve!.should be_true
    i.discount.should == 0
    i.total_discount.should == 0
    i.total_taxes.should == 0

    # To allow deliver
    i.deliver = true
    i.save.should be_true

    hash = {:ref_number => 'I-001', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :transaction_id => i.id,
      :inventory_operation_details_attributes => [
        {:item_id => 1, :quantity => 0},
        {:item_id => 2, :quantity => 0},
        {:item_id => 5, :quantity => 3}
      ]
    }

    io = InventoryOperation.new(hash)

    io.inventory_operation_details.size.should == 3
    io.save_transaction.should be_true
    io.should be_persisted

    i.reload
    i.transaction_details.last.balance.should == 2

    hash = {:ref_number => 'I-002', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :transaction_id => i.id,
      :inventory_operation_details_attributes => [
        {:item_id => 1, :quantity => 0},
        {:item_id => 2, :quantity => 0},
        {:item_id => 5, :quantity => 3}
      ]
    }

    # Exeed the quantity in the balance of a transaction item
    hash[:transaction_id].should == i.id
    io = InventoryOperation.new(hash)

    io.save_transaction.should be_false
    io.transaction_id.should == i.id
    i.reload

    io.inventory_operation_details[2].errors[:quantity].should_not be_blank

    hash = {:ref_number => 'I-0012', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :transaction_id => i.id,
      :inventory_operation_details_attributes => [
        {:item_id => 1, :quantity => 0},
        {:item_id => 2, :quantity => 0},
        {:item_id => 5, :quantity => 2}
      ]
    }

    io = InventoryOperation.new(hash)
    io.save_transaction.should be_true
    io.should be_persisted

    i.reload
    i.transaction_details.last.balance.should == 0
  end

  scenario "Make a transference between two stores" do
    store2 = Store.create!(:name => 'Second store', :address => 'An address') {|s| s.id = 2 }

    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => client.id, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    io = InventoryOperation.new(hash)
    io.inventory_operation_details.size.should == 2
    io.save_operation.should be_true
    io.should be_persisted
    io.reload
    io.creator_id.should == UserSession.user_id

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100

    store = Store.find(1)

    trans = Models::InventoryOperation::Transference.new(store)
    trans.store_out.id.should == 1
    trans.inventory_operation_out.operation.should == "transout"

  end
end
