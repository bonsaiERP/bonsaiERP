# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

feature "Buy edit", "test features" do
  background do
    #create_organisation_session
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    create_user_session
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }
  let(:item_ids) {Item.org.map(&:id)}
  let!(:bank) { create_bank(:number => '123', :amount => 1000) }
  let(:bank_account) { bank.account }
  let!(:supplier) { create_supplier(:matchcode => 'Karina Luna') }
  let!(:tax) { Tax.create(:name => "Tax1", :abbreviation => "ta", :rate => 10)}
  let!(:store) { 
    Store.create!(:name => 'First store', :address => 'An address') {|s| s.id = 1 }
  }

  #background do
  #  hash = {:ref_number => 'I-0001', :date => Date.today, :contact_id => supplier.id, :operation => 'in', :store_id => 1,
  #    :inventory_operation_details_attributes => [
  #      {:item_id =>1, :quantity => 100},
  #      {:item_id =>2, :quantity => 100},
  #      {:item_id =>3, :quantity => 100},
  #      {:item_id =>4, :quantity => 100}
  #    ]
  #  }
  #  io = InventoryOperation.new(hash)
  #  io.save_operation.should be_true
  #end

  let(:buy_params) do
      d = Date.today
      i_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id" => supplier.id, 
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

  scenario "Edit a buy, pay and check that the client has the amount, and check states" do
    b = Buy.new(buy_params)
    b.save_trans.should be_true

    b.balance.should == 3 * 10 + 5 * 20
    bal = b.balance

    b.total.should == b.balance
    b.should be_draft
    b.transaction_histories.should be_empty
    b.modified_by.should == UserSession.user_id

    # Approve income
    b.approve!.should be_true
    b.should_not be_draft
    b.should be_approved


    b = Buy.find(b.id)
    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance - 2, :exchange_rate => 1, :reference => 'Cheque 143234')
    b.save_payment.should be_true
    p.should be_persisted
    p.should_not be_conciliation
    b.reload

    b.should_not be_paid
    p.should be_persisted
    b.balance.should == 2
    p.transaction_id.should == b.id

    p = AccountLedger.find(p.id)
    p.conciliate_account.should be_true

    p.reload
    p.should be_conciliation
    
    bank_account.reload
    bank_account.amount.should == 1000 - p.amount.abs

    paid_amt = p.amount.abs
    ## Diminish the quantity in edit and the amount should go to the client account
    b = Buy.find(b.id)

    edit_params = buy_params.dup
    edit_params[:transaction_details_attributes][0][:id] = b.transaction_details[0].id

    edit_params[:transaction_details_attributes][1][:id] = b.transaction_details[1].id

    edit_params[:transaction_details_attributes][1][:quantity] = 5
    b.attributes = edit_params
    b.save_trans.should be_true

    b.total.should < paid_amt
    to_pay = paid_amt - b.total
    supplier.account_cur(1)
    #puts supplier.account_cur(1).amount
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
    #ac.amount.should == -(bal - i.balance)

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
    b = Buy.new(buy_params)
    b.save_trans.should be_true

    b.balance.should == 3 * 10 + 5 * 20
    bal = b.balance

    b.total.should == b.balance
    b.should be_draft
    b.transaction_histories.should be_empty
    b.modified_by.should == UserSession.user_id

    # Approve de buy
    b.approve!.should be_true
    b.should_not be_draft
    b.should be_approved


    b = Buy.find(b.id)
    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'out')
    b.save_payment
    b.current_ledger.should be_persisted
    b.current_ledger.transaction_type.should == "Buy"
    b.reload

    b.should be_paid
    p.should be_persisted
    b.balance.should == 0
    # Needed
    p = AccountLedger.find(p.id)
    p.conciliate_account.should be_true
    
    p.should be_conciliation

    b.reload

    # IO operation for buy
    h = {
      transaction_id: b.id, operation: 'in', store_id: 1
    }

    io = InventoryOperation.new(h)
    io.set_transaction
    io.inventory_operation_details[0].quantity = 5
    io.save_transaction.should be_true
    io.should be_persisted
    io.reload

    b.transaction_details(true)
    b.transaction_details[0].balance.should == 5
    b.transaction_details[1].balance.should == 0

    # Should not allow change of quantity lesser than delivered
    b = Buy.find(b.id)
    b.transaction_details[0].quantity = 4
   
    b.save_trans.should be_false
    b.transaction_details[0].errors[:quantity].should_not be_empty

    det1 = b.transaction_details[0]
    det2 = b.transaction_details[1]

    # Do not allow change of item id If item has any number of delivered
    b = Buy.find(b.id)
    b.attributes = {
      transaction_details_attributes: [
        {id: det1.id, item_id: 3, quantity: 6, price: det1.price},
        {id: det2.id, item_id: det2.item_id, quantity: det2.quantity, price: det2.price}
      ]
    }
    #i.transaction_details[0].item_id = 3
    #i.transaction_details[0].quantity = 6

    b.transaction_details[0].quantity.should == 6
    b.transaction_details[0].item_id.should == 3

    b.save_trans.should be_false
    b.transaction_details[0].errors[:item_id].should_not be_empty
    b.transaction_details[0].item_id.should == 1

    # Should not allow destroy for items that have been delivered
    b = Buy.find(b.id)
    b.attributes = {
      transaction_details_attributes: [
        {id: det1.id, item_id: det1.item_id, quantity: det1.quantity, price: det1.price},
        {id: det2.id, item_id: det2.item_id, quantity: det2.quantity, price: det2.price, _destroy: "1"}
      ]
    }

    b.transaction_details[1].should be_marked_for_destruction

    b.save_trans.should be_false
    b.transaction_details[1].errors[:item_id].should_not be_empty
    b.transaction_details[1].should_not be_marked_for_destruction
  end

  scenario "Make a devolution" do
    pro = Project.create!(name: "Test project")
    b = Buy.new(buy_params.merge(project_id: pro.id))
    b.save_trans.should be_true

    b.balance.should == 3 * 10 + 5 * 20
    b.project_id.should == pro.id
    bal = b.balance

    b.modified_by.should == UserSession.user_id

    # Approve income
    b.approve!.should be_true
    b.should_not be_draft

    b.approve_credit(credit_reference: "Credit 001", credit_description: "OK").should be_true
    b.pay_plans.count.should == 1

    pp = b.pay_plans.first
    pp.should be_persisted
    b.edit_pay_plan(pp.id, payment_date: Date.today + 10.days, amount: 20, repeat: "1")
    b.save_pay_plan.should be_true

    pp_size = (b.total/20).ceil
    b.pay_plans(true).count.should == pp_size
    b.pay_plans.unpaid.count.should == pp_size

    p = b.new_payment(reference: "First payment, almost all", base_amount: b.total, exchange_rate: 1, account_id: bank_account.id)
    b.save_payment.should be_true
    b.balance.should == 0

    b.pay_plans(true).unpaid.count.should == 0
    p.conciliate_account.should be_true

    b.should_not be_devolution

    dev_amt, ac = 20, supplier.account_cur(b.currency_id)
    dev = b.new_devolution(base_amount: dev_amt, account_id: ac.id, reference: "First devolution", exchange_rate: 1)
    b.save_devolution.should be_true

    b.should be_devolution
    
    dev.should be_persisted
    dev.project_id.should == pro.id

    tot_ac = ac.amount

    b.reload
    b.pay_plans(true).unpaid.count.should == 1
    b.pay_plans_balance.should == 20

    dev.should be_persisted

    dev.conciliate_account.should be_true
    ac.reload
    ac.amount.should == -(tot_ac + dev_amt)

  end

end

