# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Inventory Operation", "Test IN/OUT" do
  background do

    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    Store.create!(:name => 'First store', :address => 'An address') {|s| s.id = 1 }

    create_items
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:supplier) { create_supplier(:matchcode => 'Proveedor 1')}
  let!(:client) { create_client(:matchcode => 'Cliente 1')}
  let(:income_params) {
    d = Date.today
    i_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id" => client.id, 
      "exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount" => 3, "project_id"=>1 
    }
    details = [
      { "description"=>"jejeje", "item_id"=>1, "organisation_id"=>1, "price"=>3, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>5, "quantity"=> 20}
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
    io.reload
    io.creator_id.should == UserSession.user_id

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 200

    puts "Add the same items updates the quantity"

    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
    io.reload

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 200

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 400

  end

  scenario "create OUT" do

    puts "Create first and IN"
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    io = InventoryOperation.new(hash)
    io.inventory_operation_details.size.should == 2
    io.save_operation.should == true

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 200

    puts "Create an OUT"

    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 50},
        {:item_id =>2, :quantity => 100}
      ]
    }

    io = InventoryOperation.new(hash)
    io.save_operation.should be_true

    io.reload

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 50

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 100

  end

  scenario "make OUT for Income" do
    i = Income.new(income_params)
    i.save_trans.should be_true
    i.approve!.should be_true

    i.balance.should == i.balance_inventory

    det = i.transaction_details[0]
    det.balance.should == det.quantity
    
    bank = Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 0)

    p = i.new_payment(:account_id => bank.account_id, :reference => "N/A", :exchange_rate => 1)
    p.amount.should == i.balance
    i.save_payment.should be_true

    # Create inventory for the stock
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :store_id => 1, :operation => 'in',
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    
    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
    
    puts "Create and OUT for Income"

    hash = hash.merge(:transaction_id => i.id)

    io = InventoryOperation.new(hash)
    io.save_transaction.should be_false

    io.inventory_operation_details[0].errors.should_not == blank?
    io.inventory_operation_details[1].errors.should_not == blank?

    puts "Saving correctly"
    io.inventory_operation_details[0].quantity = 5
    io.inventory_operation_details[1].quantity = 10

    io.save_transaction.should be_true

    i.reload
    i.balance_inventory.should_not == i.balance

    dets = i.transaction_details(true)

    det1 = dets[0]
    det2 = dets[1]

    #i.balance_inventory.should == i.total - (5 * det1.price + 10 * det2.price)

    det1.balance.should == 5
    det2.balance.should == 10
  end

  scenario "Make an OUT for income with some values with 0" do
    i = Income.new(income_params)
    i.save.should == true
    i.approve!

    i.balance.should == i.balance_inventory

    det = i.transaction_details[0]
    det.balance.should == det.quantity
    
    Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 0) {|a| a.id = 1 }

    p = i.new_payment(:account_id => 1, :reference => "NA", :date => Date.today)
    p.amount.should == i.balance
    p.save.should == true

    # Create inventory
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 200}
      ]
    }
    
    io = InventoryOperation.new(hash)
    io.save.should == true

    io.store.stocks(true).unscoped.size.should == 2
    # Check the stocks
    stocks = Hash[ Store.find(1).stocks.map {|st| [st.item_id, st.quantity] } ]

    puts "Create and OUT for Income with 0 quantity"

    hash = hash.merge(:transaction_id => i.id)

    io = InventoryOperation.new(hash)
    io.inventory_operation_details[0].quantity = 0
    io.inventory_operation_details[1].quantity = 10

    io.save.should == true

    io.store.stocks(true)
    io.store.stocks.find_by_item_id(1).quantity.should == stocks[1]
    io.store.stocks.find_by_item_id(2).quantity.should == stocks[2] - 10

    io.store.stocks.unscoped.size.should == 3
  end
end
