# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

def set_inventory_details(args)
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
end
