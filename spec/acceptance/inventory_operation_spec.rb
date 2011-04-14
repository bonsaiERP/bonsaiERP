# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

def income_params
    d = Date.today
    @income_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id"=>1, 
      "currency_exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount"=>3, "project_id"=>1 
    }
    details = [
      { "description"=>"jejeje", "item_id"=>1, "organisation_id"=>1, "price"=>15.5, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>10, "quantity"=> 20}
    ]
    @income_params[:transaction_details_attributes] = details
    @income_params
end

feature "Inventory Operation", "Test IN/OUT" do
  background do

    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    Store.create!(:name => 'First store', :address => 'An address') {|s| s.id = 1 }

    Supplier.create!(:name => 'karina', :last_name => 'Luna Pizarro', :matchcode => 'Karina Luna (Prov.)', :address => 'Mallasa') {|c| c.id = 1 }
    Client.create!(:name => 'karina', :last_name => 'Luna Pizarro', :matchcode => 'Karina Luna (Cli.)', :address => 'Mallasa') {|c| c.id = 2 }

    create_items
  end

  scenario 'make an IN' do
    #Item.org.each {|it| puts "#{it} :: #{it.ctype} :: #{it.unitary_cost}" }
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100, :unitary_cost => 2},
        {:item_id =>2, :quantity => 200, :unitary_cost => 2.5}
      ]
    }
    io = InventoryOperation.new(hash)
    io.inventory_operation_details.size.should == 2
    io.save.should == true

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100
    io.store.stocks[0].unitary_cost.should == 2

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 200
    io.store.stocks[1].unitary_cost.should == 2.5

    puts "Add the same items updates the cost and quantity"

    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100, :unitary_cost => 2},
        {:item_id =>2, :quantity => 200, :unitary_cost => 2}
      ]
    }
    io = InventoryOperation.new(hash)
    io.save.should == true
    io.reload

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 200
    io.store.stocks[0].unitary_cost.should == 2

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 400
    io.store.stocks[1].unitary_cost.should == 2.25

  end

  scenario "create OUT" do

    puts "Create first and IN"
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100, :unitary_cost => 2},
        {:item_id =>2, :quantity => 200, :unitary_cost => 2.5}
      ]
    }
    io = InventoryOperation.new(hash)
    io.inventory_operation_details.size.should == 2
    io.save.should == true

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 100
    io.store.stocks[0].unitary_cost.should == 2

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 200
    io.store.stocks[1].unitary_cost.should == 2.5

    puts "Create an OUT"

    hash = {:ref_number => 'I-0002', :date => Date.today, :contact_id => 1, :operation => 'out', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 50},
        {:item_id =>2, :quantity => 100}
      ]
    }

    io = InventoryOperation.new(hash)
    io.save.should == true

    io.store.stocks[0].item_id.should == 1
    io.store.stocks[0].quantity.should == 50
    io.store.stocks[0].unitary_cost.should == 2

    io.store.stocks[1].item_id.should == 2
    io.store.stocks[1].quantity.should == 100
    io.store.stocks[1].unitary_cost.should == 2.5

  end

  scenario "make OUT for Income" do
    i = Income.new(income_params)
    i.save.should == true
    i.approve!
    
    Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 0) {|a| a.id = 1 }

    p = i.new_payment(:account_id => 1, :reference => "NA", :date => Date.today)
    p.amount.should == i.balance
    p.save.should == true

    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => 1, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100, :unitary_cost => 2},
        {:item_id =>2, :quantity => 200, :unitary_cost => 2.5}
      ]
    }
    
    io = InventoryOperation.new(hash)
    io.save.should == true
    
    puts "Create and OUT for Income"

    hash = hash.merge(:transaction_id => i.id, :operation => 'out')

    io = InventoryOperation.new(hash)
    puts "----------------------"
    io.save.should == false
  end
end
