# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

feature "Income", "test features" do
  background do
    #create_organisation_session
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    create_user_session
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }
  let(:item_ids) {Item.org.map(&:id)}
  let!(:bank) { create_bank(:number => '123', :amount => 0) }
  let(:bank_account) { bank.account }
  let!(:client) { create_client(:matchcode => 'Karina Luna') }
  let!(:tax) { Tax.create(:name => "Tax1", :abbreviation => "ta", :rate => 10)}
  let!(:store) { 
    Store.create!(:name => 'First store', :address => 'An address') {|s| s.id = 1 }
  }

  background do
    hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => client.id, :operation => 'in', :store_id => 1,
      :inventory_operation_details_attributes => [
        {:item_id =>1, :quantity => 100},
        {:item_id =>2, :quantity => 100},
        {:item_id =>3, :quantity => 100},
        {:item_id =>4, :quantity => 100}
      ]
    }
    io = InventoryOperation.new(hash)
    io.save_operation.should be_true
  end

  let(:income_params) do
      d = Date.today
      i_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id" => client.id, 
        "exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
        "description"=>"Esto es una prueba", "discount" => 0, "project_id"=>1 
      }

      details = [
        { "description"=>"jejeje", "item_id"=>1, "price"=>3, "quantity"=> 10},
        { "description"=>"jejeje", "item_id"=>2, "price"=>5, "quantity"=> 20}
      ]
      i_params[:transaction_details_attributes] = details
      i_params
  end

  let(:pay_plan_params) do
    d = options[:payment_date] || Date.today
    {:alert_date => (d - 5.days), :payment_date => d,
     :ctype => 'Income', :description => 'Prueba de vida!', 
     :email => true }.merge(options)
  end

  scenario "Edit a income and save history" do
    i = Income.new(income_params)
    i.save_trans.should be_true

    i.balance.should == 3 * 10 + 5 * 20
    i.total.should == i.balance
    i.should be_draft
    i.transaction_histories.should be_empty
    i.modified_by.should == UserSession.user_id

    # Approve de income
    i.approve!.should be_true
    i.should_not be_draft
    i.should be_approved

    i = Income.find(i.id)
    # Diminish the quantity in edit and the amount should go to the client account
    #i = Income.find(i.id)
    edit_params = income_params.dup
    edit_params[:transaction_details_attributes][0][:id] = i.transaction_details[0].id

    edit_params[:transaction_details_attributes][1][:id] = i.transaction_details[1].id
    edit_params[:transaction_details_attributes][1][:quantity] = 5
    edit_params[:transaction_details_attributes][1][:price] = 5.5
    i.attributes = edit_params
    i.save_trans.should be_true
    i.reload

    i.transaction_details[1].quantity.should == 5
    i.transaction_details[1].balance.should == 5
    
    i.transaction_histories.should_not be_empty
    hist = i.transaction_histories.first
    hist.user_id.should == i.modified_by

    i.transaction_details[1].quantity.should == 5
    i.balance.should == 3 * 10 + 5 * 5.5

    hist.data[:transaction_details][0][:quantity].should == 10
    hist.data[:transaction_details][1][:quantity].should == 20
    hist.data[:transaction_details][1][:price].should == 5

    i.transaction_details[1].price.should == 5.5

    # Check changes on income in contact_id and ref_number
    contact_id, ref_number, currency_id, exchange_rate = i.contact_id, i.ref_number, i.currency_id, i.exchange_rate
    i.should_not be_draft
    i = Income.find(i.id)
    i.attributes = {ref_number: "NEW CHANGED"}
    i.ref_number.should == "NEW CHANGED"
    i.save_trans.should be_false
    i.ref_number.should == ref_number

    i = Income.find(i.id)
    i.attributes = {contact_id: 100}
    i.contact_id.should == 100
    i.save_trans.should be_false
    i.contact_id.should == contact_id

    # Check change of exchange_rate and currency
    i = Income.find(i.id)
    i.attributes = {currency_id: 100, exchange_rate: 2}
    i.contact_id.should == 1
    i.save_trans.should be_false
    i.currency_id.should == currency_id
    i.exchange_rate.should == exchange_rate
  end


  scenario "Edit a income, pay and check that the client has the amount, and check states" do
    i = Income.new(income_params)
    i.save_trans.should be_true

    i.balance.should == 3 * 10 + 5 * 20
    bal = i.balance

    i.total.should == i.balance
    i.should be_draft
    i.transaction_histories.should be_empty
    i.modified_by.should == UserSession.user_id

    # Approve income
    i.approve!.should be_true
    i.should_not be_draft
    i.should be_approved


    i = Income.find(i.id)
    p = i.new_payment(:account_id => bank_account.id, :base_amount => i.balance, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'in')
    i.save_payment.should be_true
    p.should be_persisted
    p.should_not be_conciliation
    i.reload

    i.should_not be_deliver
    i.should be_paid
    p.should be_persisted
    i.balance.should == 0
    p.transaction_id.should == i.id

    p = AccountLedger.find(p.id)
    p.conciliate_account.should be_true

    p.reload
    p.should be_conciliation
    
    bank_account.reload
    bank_account.amount.should == p.amount
    # Diminish the quantity in edit and the amount should go to the client account
    i = Income.find(i.id)

    old_tot = i.total

    i.account_ledgers.pendent.should be_empty
    i.balance.should == 0
    i.should be_deliver
    i.should be_paid

    edit_params = income_params.dup
    edit_params[:transaction_details_attributes][0][:id] = i.transaction_details[0].id

    edit_params[:transaction_details_attributes][1][:id] = i.transaction_details[1].id
    edit_params[:transaction_details_attributes][1][:quantity] = 5
    i.attributes = edit_params
    i.save_trans.should be_false
    i.errors[:base].should_not be_empty

    # Make a devolution for the payment

    #puts i.errors.messages

    #i.reload
    #
    #i.should be_paid
    #i.balance.should == 0
    #i.transaction_histories.should_not be_empty
    #hist = i.transaction_histories.first
    #hist.user_id.should == i.modified_by

    #i.transaction_details[1].quantity.should == 5
    #i.total.should == 3 * 10 + 5 * 5
    #i.balance.should == 0

    #ac = client.account_cur(i.currency_id)
    ##ac.amount.should == -(bal - i.balance)

    ## Edit and change the amount so the state changes
    #i = Income.find(i.id)
    #edit_params = income_params.dup
    #edit_params[:transaction_details_attributes][0][:id] = i.transaction_details[0].id

    #edit_params[:transaction_details_attributes][1][:id] = i.transaction_details[1].id
    #edit_params[:transaction_details_attributes][1][:quantity] = 5.1

    #i.attributes = edit_params
    #i.save_trans.should be_true
    #i.reload

    #i.should be_approved
    #i.should_not be_deliver
    #i.total.should ==  3 * 10 + 5 * 5.1
    #i.balance.should ==  5 * 0.1

    ## Change to  paid when changed again with the price
    #i = Income.find(i.id)
    #edit_params = income_params.dup
    #edit_params[:transaction_details_attributes][0][:id] = i.transaction_details[0].id

    #edit_params[:transaction_details_attributes][1][:id] = i.transaction_details[1].id
    #edit_params[:transaction_details_attributes][1][:quantity] = 5

    #i.attributes = edit_params
    #i.save_trans.should be_true
    #i.reload

    #i.should be_paid
    #i.total.should ==  3 * 10 + 5 * 5
    #i.balance.should ==  0
    #i.should be_deliver
  end

  scenario "check the number of items" do
    i = Income.new(income_params)
    i.save_trans.should be_true

    i.balance.should == 3 * 10 + 5 * 20
    bal = i.balance

    i.total.should == i.balance
    i.should be_draft
    i.transaction_histories.should be_empty
    i.modified_by.should == UserSession.user_id

    # Approve de income
    i.approve!.should be_true
    i.should_not be_draft
    i.should be_approved


    i = Income.find(i.id)
    p = i.new_payment(:account_id => bank_account.id, :base_amount => i.balance, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'out')
    i.save_payment
    i.reload

    i.should be_paid
    p.should be_persisted
    i.balance.should == 0
    # Needed
    p = AccountLedger.find(p.id)
    p.conciliate_account.should be_true
    
    p.should be_conciliation

    i.reload
    i.should be_deliver

    # IO operation for income
    h = {
      transaction_id: i.id, operation: 'out', store_id: 1
    }

    io = InventoryOperation.new(h)
    io.set_transaction
    io.inventory_operation_details[0].quantity = 5
    io.save_transaction.should be_true
    io.should be_persisted
    io.reload

    i.transaction_details(true)
    i.transaction_details[0].balance.should == 5
    i.transaction_details[1].balance.should == 0

    # Should not allow change of quantity lesser than delivered
    i = Income.find(i.id)
    i.transaction_details[0].quantity = 4
   
    i.save_trans.should be_false
    i.transaction_details[0].errors[:quantity].should_not be_empty

    det1 = i.transaction_details[0]
    det2 = i.transaction_details[1]

    # Do not allow change of item id If item has any number of delivered
    i = Income.find(i.id)
    i.attributes = {
      transaction_details_attributes: [
        {id: det1.id, item_id: 3, quantity: 6, price: det1.price},
        {id: det2.id, item_id: det2.item_id, quantity: det2.quantity, price: det2.price}
      ]
    }
    #i.transaction_details[0].item_id = 3
    #i.transaction_details[0].quantity = 6

    i.transaction_details[0].quantity.should == 6
    i.transaction_details[0].item_id.should == 3

    i.save_trans.should be_false
    i.transaction_details[0].errors[:item_id].should_not be_empty
    i.transaction_details[0].item_id.should == 1

    # Should not allow destroy for items that have been delivered
    i = Income.find(i.id)
    i.attributes = {
      transaction_details_attributes: [
        {id: det1.id, item_id: det1.item_id, quantity: det1.quantity, price: det1.price},
        {id: det2.id, item_id: det2.item_id, quantity: det2.quantity, price: det2.price, _destroy: "1"}
      ]
    }

    i.transaction_details[1].should be_marked_for_destruction

    i.save_trans.should be_false
    i.transaction_details[1].errors[:item_id].should_not be_empty
    i.transaction_details[1].should_not be_marked_for_destruction
  end

  scenario "Should not allow greater values" do
    i = Income.new(income_params)
    i.save_trans.should be_true

    bal = i.balance
    i.approve!.should be_true
    p = i.new_payment(reference: "Idfdf", base_amount: bal -1, account_id: bank_account.id, exchange_rate: 1)
    i.save_payment.should be_true
    i.balance.should == 1

    i = Income.find(i.id)
    p = i.new_payment(reference: "Idfdf", base_amount: 1.20, account_id: bank_account.id, exchange_rate: 1)
    i.save_payment.should be_false
    p.errors[:base_amount].should_not be_blank

    # New payment and check balance
    i = Income.find(i.id)
    p = i.new_payment(reference: "Idfdf", base_amount: 1.10, account_id: bank_account.id, exchange_rate: 1)
    i.save_payment.should be_true
    i.balance.should == 0

  end

  scenario "Should not allow greater values with other currency" do
    i = Income.new(income_params.merge(currency_id: 2, exchange_rate: 2))
    i.save_trans.should be_true

    bal = i.balance
    i.approve!.should be_true

    i = Income.find(i.id)
    p = i.new_payment(reference: "Idfdf", base_amount: bal * 2 + 1, account_id: bank_account.id, exchange_rate: 2)
    i.save_payment.should be_false
    p.should be_inverse

    i = Income.find(i.id)
    p = i.new_payment(reference: "Idfdf", base_amount: bal * 2, account_id: bank_account.id, exchange_rate: 2)

    i.save_payment.should be_true

    p = AccountLedger.find(p.id)
    p.should be_persisted
    p.should be_inverse

    i.balance.should == 0
  end
end
