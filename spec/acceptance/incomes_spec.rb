# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

def income_params
    d = Date.today
    @income_params = {"active"=>nil, "bill_number"=>"56498797", "account_id"=>1, 
      "exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount" => 3, "project_id"=>1 
    }
    details = [
      { "description"=>"jejeje", "item_id"=>1, "organisation_id"=>1, "price"=>3, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>5, "quantity"=> 20}
    ]
    @income_params[:transaction_details_attributes] = details
    @income_params
end

def pay_plan_params(options)
  d = options[:payment_date] || Date.today
  {:alert_date => (d - 5.days), :payment_date => d,
   :interests_penalties => 0,
   :ctype => 'Income', :description => 'Prueba de vida!', 
   :email => true }.merge(options)
end

feature "Income", "test features" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1, :preferences => {:item_discount => 0, :general_discount => 0})
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    create_organisation(:id => 1)
    create_items

    @b1 = create_bank(:number => '123', :amount => 0)
    @ac1_id = @b1.account.id
    #CashRegister.create!(:name => 'Cash register Bs.', :amount => 0, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}
    #CashRegister.create!(:name => 'Cash register $.', :amount => 0, :currency_id => 2, :address => 'None') {|cr| cr.id = 3}

    @c1 = create_client(:matchcode => 'Karina Luna')
    @cli1_id = @c1.account.id

  end

  scenario "Create a payment with nearest pay_plan" do
    i = Income.new(income_params.merge(:account_id => @cli1_id))

    i.cash.should == true
    i.save_trans.should == true

    i.reload
    i.transaction_details.size.should == 2
    i.cash.should == true
    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total
    i.total_currency.should == i.total
    i.state.should == "draft"

    # check details
    i.transaction_details[0].balance.should == 10
    i.transaction_details[0].original_price.should == 3
    i.transaction_details[1].balance.should == 20
    i.transaction_details[1].original_price.should == 5

    a1 = Account.find(i.account_id)
    a1.amount.should == 0
    a2 = Account.org.find_by_original_type("Income")
    a2.amount.should == 0

    i.approve!.should == true
    i.reload
    i.approver_id.should == 1
    i.state.should == "approved"
    i.account_ledger.should_not == nil

    al = i.account_ledger
    al.operation.should == "transaction"
    al.reference.should == "Venta #{i.ref_number}"
    a1.reload
    a2.reload

    # Check amounts for accounts
    a1.amount.should == i.total_currency
    a2.amount.should == -i.total_currency

    # Create a payment
    i.payment?.should == false

    p = i.new_payment(:account_id => @ac1_id, :amount => 30, :exchange_rate => 1, :reference => 'Cheque 143234')
    p.class.should == AccountLedger
    p.payment?.should == true
    p.operation.should == 'in'
    p.amount.should == 30
    p.interests_penalties.should == 0

    i.payment?.should == true

    bal = i.balance

    i.save_payment.should == true

    i.balance.should == bal - 30
    ac1 = p.account_ledger_details[0].account
    ac2 = p.account_ledger_details[1].account

    ac1.amount.should == 0
    ac2.amount.should == i.total

    p.conciliate_account.should == true
    p.approver_id.should == UserSession.user_id
    p.approver_datetime.kind_of?(Time).should == true

    p.account_ledger_details(true).map(&:state).uniq.should == ['con']

    ac1.amount.should == 30

    ac1.reload
    ac2.reload

    ac1.amount.should == 30
    ac2.amount.should == i.total - 30

    i.deliver.should == false
    
    p = i.new_payment(:account_id => @ac1_id, :amount => i.balance, :reference => 'Cheque 222289', :exchange_rate => 1)

    i.save_payment.should == true

    p.conciliation.should == false
    i.state.should == 'paid'
    i.deliver.should == false


    # Conciliation
    p.conciliate_account.should == true
    p.reload

    p.conciliation.should == true
    i.reload
    i.balance.should == 0
    p.conciliation.should == true
    i.deliver.should == true

    ac1.reload
    ac2.reload

    ac1.amount.should == i.total
    ac2.amount.should == 0
    
  end

  scenario "Create a an income with credit" do
    i = Income.new(income_params.merge(:account_id => @cli1_id))
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    # Create PayPlan
    d = Date.today
    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30)
    pp.should == false

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true
    i.reload
    i.cash.should == false
    i.pay_plans.size.should == 1
    i.pay_plans.first.amount.should == i.balance
    i.payment_date.should == i.pay_plans.first.payment_date
    
    i.credit?.should == true
    i.creditor_id.should == UserSession.user_id
    i.credit_datetime.should_not == blank?

    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30)

    pp.transaction_id.should == i.id
    pp.currency_id.should == i.currency_id

    i.save_pay_plan.should == true
    i.reload
    i.pay_plans.size.should == 2
    i.payment_date.should == i.pay_plans.first.payment_date

    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    i.new_pay_plan(:payment_date => d + 1.month, :alert_date => d - 5.days, :amount => 30, :repeat => "1")
    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.size.should == (i.balance/30).ceil
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # delete many pay_plans
    pp_ids = i.pay_plans[2..i.pay_plans.size].map(&:id)
    i.destroy_pay_plans(pp_ids).should == true
    i.reload

    i.pay_plans.size.should == 3
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    pp = i.pay_plans.last
    i.new_pay_plan(:payment_date => pp.payment_date, :alert_date => pp.alert_date, :amount => 30, :repeat => "true")
    i.save_pay_plan.should == true

    i.pay_plans.unpaid.size.should == (i.balance/30).ceil
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # Create a payment
    p = i.new_payment(:account_id => @ac1_id, :exchange_rate => 1, :reference => 'Cheque 143234')
    # Payment should have the amount of the first unpaid pay_plan
    p.interests_penalties.should == 0
    p.amount.should == 30

    i.save_payment.should == true
    i.reload
    
    i.pay_plans.unpaid.size.should == (i.total/30).ceil - 1
    i.balance.should == i.total - 30
    p.amount.should == 30
    ac1 = p.account
    ac2 = p.to

    ac1_amt = ac1.amount
    ac2_amt = ac2.amount

    p.conciliate_account.should == true

    ac1.reload
    ac2.reload
    
    ac1.amount.should == ac1_amt + 30
    ac1.cur(1).amount.should == ac1_amt + 30
    ac2.amount.should == ac2_amt - 30
    ac2.cur(1).amount.should == ac2_amt - 30

    # Payment that is nulled
    bal = i.balance
    p = i.new_payment(:account_id => @ac1_id, :exchange_rate => 1, :reference => 'Cheque 143234')
    p.interests_penalties.should == 0

    i.save_payment.should == true
    i.reload
    i.balance.should == bal - 30
    i.pay_plans.unpaid.size.should == (i.total/30).ceil - 2
    p.conciliation.should == false

    p.null_account.should == true
    i.reload
    i.balance.should == bal
  end

end
