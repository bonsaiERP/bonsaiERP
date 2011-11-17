# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

feature "Buy", "test features" do

  background do
    create_organisation_session
    create_user_session
  end

  let(:pay_plan_params) do
    d = options[:payment_date] || Date.today
    {:alert_date => (d - 5.days), :payment_date => d,
     :interests_penalties => 0,
     :ctype => 'Buy', :description => 'Prueba de vida!', 
     :email => true }.merge(options)
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }
  let!(:bank) { create_bank(:number => '123', :amount => 0) }
  let(:bank_account) { bank.account }
  let!(:supplier) { create_supplier(:matchcode => 'Manuel Morales') }
  let!(:client) { create_client(:matchcode => "Karina Luna")}
  let(:buy_params) do
      d = Date.today
      buy_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id"=> supplier.id, 
        "exchange_rate"=>1, "currency_id"=>1, "date"=> d, 
        "description"=>"Esto es una prueba", "discount" => 3, "project_id"=>1 
      }
      details = [
        { "description"=>"jejeje", "item_id"=>1, "price"=>3, "quantity"=> 10},
        { "description"=>"jejeje", "item_id"=>2, "price"=>5, "quantity"=> 20}
      ]
      buy_params[:transaction_details_attributes] = details
      buy_params
  end

  scenario "Create a buy" do

    log.info "Creating new buy"
    b = Buy.new(buy_params)

    b.should be_cash
    b.save_trans.should be(true)
    b.should be_draft

    b = Buy.find(b.id)
    log.info "Checking details, cash and balance for buy"
    b.transaction_details.size.should == 2
    b.should be_cash
    tot = ( 3 * 10 + 5 * 20 )
    b.total.should == tot.round(2)
    b.balance.should == b.total
    b.total_currency.should == b.total
    b.should be_draft

    b.transaction_details[0].balance.should == 10
    b.transaction_details[0].original_price.should == 3
    b.transaction_details[1].balance.should == 20
    b.transaction_details[1].original_price.should == 5

    b.approve!.should == true
    b.reload
    b.approver_id.should == 1
    b.state.should == "approved"

    # Create a payment
    b.payment?.should == false

    p = b.new_payment(:account_id => bank_account.id, :base_amount => 30, :exchange_rate => 1, :reference => 'Cheque 143234')
    p.class.should == AccountLedger
    p.payment?.should == true
    p.operation.should == 'out'
    p.amount.should == 30
    p.interests_penalties.should == 0

    b.save_payment.should be_false
    #b.payment?.should == false
    p.errors[:amount].should_not be_blank

    # Must reload so it sets again to the original values balance
    b.reload
    # Make an in in the bank to verify
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :contact_id => client.id, :amount => 500, :reference => "Check 1120012" )

    al.save.should be_true
    al.conciliate_account.should be_true

    bank_account.reload
    bank_account.amount.should == 500

    bal = b.balance
    p = b.new_payment(:account_id => bank_account.id, :base_amount => 30, :exchange_rate => 1, :reference => 'Cheque 143234')

    b.save_payment.should be_true
    p.should be_persisted

    #p.to_id.should == Account.org.find_by_original_type(b.class.to_s).id
    p.description.should_not == blank?
    p.amount.should == -30

    b.reload
    b.balance.should == bal - 30

    p.should_not be_conciliation

    p.conciliate_account.should be_true

    p.approver_id.should == UserSession.user_id
    p.approver_datetime.kind_of?(Time).should == true

    bank_account.reload
    bank_account.amount.should == 500 - 30

    b.deliver.should == false
    b.reload
    
    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance, :reference => 'Cheque 222289', :exchange_rate => 1)

    b.save_payment.should be_true
    b.reload

    p.conciliation.should == false
    b.state.should == 'paid'
    b.deliver.should == false

    # Conciliation
    p.conciliate_account.should be_true
    p.reload
  
    b.reload

    p.conciliation.should be_true
    b.reload
    b.balance.should == 0
    p.conciliation.should be_true
    
  end

  scenario "Pay with staff account" do
    st = create_staff(:matchcode => "Debere pagar", :position => "Ugier")
    st.should be_persisted
    st_account = st.accounts.first
    st.accounts.first.amount.should == 0

    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :contact_id => client.id, :amount => 500, :reference => "Check 1120012" )

    al.save.should be_true
    al.conciliate_account.should be_true

    bank_account.reload
    bank_account.amount.should == 500

    al = AccountLedger.new_money(:operation => "out", :account_id => bank_account.id, :contact_id => st.id, :amount => 100, :reference => "Check 1120012" )

    al.save.should be_true
    al.conciliate_account.should be_true

    bank_account.reload
    bank_account.amount.should == 400

    st_account.reload
    st_account.amount.should == 100

    # Buy
    b = Buy.new(buy_params)

    b.should be_cash
    b.save_trans.should be(true)
    b.should be_draft

    b.save_trans.should be_true
    b.balance.should == 130
    b = Buy.find(b.id)

    b.approve!.should be_true

    p = b.new_payment(:account_id => st_account.id, :base_amount => b.balance, :reference => 'Cheque 222289', :exchange_rate => 1)
    p.class.should == AccountLedger

    b.save_payment.should be_false
    p.errors[:amount].should_not be_blank
    p.errors[:base_amount].should_not be_blank


    al = AccountLedger.new_money(:operation => "out", :account_id => bank_account.id, :contact_id => st.id, :amount => 100, :reference => "Check 1120012" )

    al.save.should be_true
    al.conciliate_account.should be_true

    bank_account.reload
    bank_account.amount.should == 300

    st_account.reload
    st_account.amount.should == 200

    b.reload

    p = b.new_payment(:account_id => st_account.id, :amount => b.balance, :reference => 'Cheque 222289', :exchange_rate => 1)

    b.save_payment.should be_true
    p.should be_persisted
    p.staff_id.should == st.id

    p.conciliate_account.should be_true
    st_account.reload
    st_account.amount.should == 70
  end

  scenario "Make payment and then null payment" do
    b = Buy.new(buy_params)
    b.save_trans.should be_true
    b = Buy.find(b.id)

    b.should be_persisted
    b.approve!.should be_true

    # Make an in in the bank to verify
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :contact_id => client.id, :amount => 500, :reference => "Check 1120012" )
    al.save.should be_true
    al.conciliate_account.should be_true

    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance, :exchange_rate => 1, :reference => 'Cheque 143234')
    p.payment?.should == true
    p.operation.should == 'out'

    b.save_payment.should be_true
    p.should be_persisted

    b.reload
    b.should be_paid
    b.balance.should == 0
    p.reload
    
    p.null_transaction.should be_true
    b.reload

    b.should be_approved
    b.balance.should == b.total

    # Pay with interests and null
    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance, :interests_penalties => 5, :exchange_rate => 1, :reference => 'Cheque 143234')

    b.save_payment.should be_true
    p.reload
    
    p.null_transaction.should be_true
    
    b.reload
    b.should be_approved
    b.balance.should == b.total

    # Pay with defferent currency
    bank2 = create_bank(:number => '1234', :amount => 500, :currency_id => 2)

    p = b.new_payment(:account_id => bank2.account.id, :base_amount => b.balance/2, :interests_penalties => 2, :exchange_rate => 2, :reference => 'Cheque 143234')

    b.save_payment.should be_true

    b.should be_paid
    p.reload

    p.null_transaction.should be_true
    b.reload

    b.balance.should == b.total
    b.should be_approved

    # make credit and null credits
    b.approve_credit(:credit_reference => "New credit").should be_true
    b.pay_plans.size.should == 1
    pp = b.pay_plans.first
    b.edit_pay_plan(pp.id, :amount => 30, :repeat => true)

    b.save_pay_plan.should be_true
    b.reload
    b.pay_plans.size.should == (b.balance/30).ceil
    b.payment_date.should == pp.payment_date

    p = b.new_payment(:reference => "New reference", :account_id => bank_account.id, :exchange_rate => 1, :currency_id => 1)
    p.amount.should == 30
    b.save_payment.should be_true

    b.reload
    p.reload

    b.balance.should == b.total - 30
    b.payment_date.should_not == pp.payment_date

    p.null_transaction.should be_true
    b.reload

    b.balance.should == b.total
    b.pay_plans_balance.should == b.total
    b.pay_plans.unpaid.first.payment_date.should == p.payment_date
  end

  scenario "Buy in other currency pay with other currency null" do
    b_params = buy_params.dup
    b_params[:currency_id]= 2
    b_params[:exchange_rate] = 2

    b = Buy.new(buy_params)
    b.save_trans.should be_true
    b = Buy.find(b.id)

    b.should be_persisted
    b.approve!.should be_true


    # Pay with interests and null
    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance * 2, :interests_penalties => 5, :exchange_rate => 0.5, :reference => 'Cheque 143234')

    b.save_payment.should be_false

    # Make an in in the bank to verify
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :contact_id => client.id, :amount => 500, :reference => "Check 1120012" )

    al.save.should be_true
    al.conciliate_account.should be_true

    b.reload

    p = b.new_payment(:account_id => bank_account.id, :base_amount => b.balance * 2, :interests_penalties => 5, :exchange_rate => 0.5, :reference => 'Cheque 143234')

    b.save_payment.should be_true
    b.should be_paid

    p.reload
    p.null_transaction.should be_true
    
    b.reload
    b.should_not be_paid
    b.balance.should == b.total

  end

end
