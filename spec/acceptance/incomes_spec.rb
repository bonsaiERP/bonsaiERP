# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

feature "Income", "test features" do

  let(:income_params) do
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

  let(:pay_plan_params) do
    d = options[:payment_date] || Date.today
    {:alert_date => (d - 5.days), :payment_date => d,
     :interests_penalties => 0,
     :ctype => 'Income', :description => 'Prueba de vida!', 
     :email => true }.merge(options)
  end

  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1, :preferences => {:item_discount => 0, :general_discount => 0})
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }
  let!(:bank) { create_bank(:number => '123', :amount => 0) }
  let(:bank_account) { bank.account }
  let!(:client) { create_client(:matchcode => 'Karina Luna') }
  let(:client_account) { client.account }

  scenario "Create a payment with nearest pay_plan" do
    i = Income.new(income_params.merge(:account_id => client_account.id))

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

    # Create a payment
    i.payment?.should == false

    p = i.new_payment(:account_id => bank_account.id, :amount => 30, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'out')
    p.class.should == AccountLedger
    p.payment?.should == true
    p.operation.should == 'in'
    p.amount.should == 30
    p.interests_penalties.should == 0
    p.to_id.should == Account.org.find_by_original_type(i.class.to_s).id

    i.payment?.should == true

    bal = i.balance

    i.save_payment.should == true

    i.balance.should == bal - 30
    ac1 = p.account_ledger_details[0].account
    ac2 = p.account_ledger_details[1].account

    ac1.original_type.should == "Bank"
    ac2.original_type.should == "Income"

    p.account_ledger_details[0].state.should == 'uncon'
    p.account_ledger_details[0].organisation_id.should be(p.organisation_id)
    p.account_ledger_details[1].state.should == 'uncon'
    p.account_ledger_details[1].organisation_id.should be(p.organisation_id)

    ac1.amount.should == 0
    ac2.amount.should == 0

    p.conciliate_account.should == true

    p.approver_id.should == UserSession.user_id
    p.approver_datetime.kind_of?(Time).should == true

    p.account_ledger_details(true).map(&:state).uniq.should == ['con']

    ac1.amount.should == 30

    ac1.reload
    ac2.reload

    ac1.amount.should == 30
    ac2.amount.should == - 30

    i.deliver.should == false
    
    p = i.new_payment(:account_id => bank_account.id, :amount => i.balance, :reference => 'Cheque 222289', :exchange_rate => 1)

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
    ac2.amount.should == -i.total
    
  end

  scenario "Create a an income with credit" do
    i = Income.new(income_params.merge(:account_id => client_account.id))
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
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234')
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
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234')
    p.interests_penalties.should == 0

    i.save_payment.should == true
    i.reload
    i.balance.should == bal - 30
    i.pay_plans.unpaid.size.should == (i.total/30).ceil - 2
    p.conciliation.should == false

    p.null_account.should == true
    i.reload
    i.balance.should == bal
    i.pay_plans.unpaid.size.should ==  (i.total/30).ceil - 1
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance
    #i.pay_plans.unpaid.each {|pp| puts "#{pp.amount} #{pp.payment_date}"}


    bal = i.balance
    size = i.pay_plans.unpaid.count
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234', :amount => 45)
    
    i.save_payment.should == true
    p.conciliate_account.should == true
    i.reload

    i.pay_plans.unpaid.size.should == size - 1
    i.balance.should == bal - 45


    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234', :amount => i.balance)
    
    i.save_payment.should == true
    i.reload
    i.pay_plans.unpaid.size.should == 0
    i.balance.should == 0
    p.conciliate_account.should == true

  end

  scenario "Create credit with interests" do
    i = Income.new(income_params.merge(:account_id => client_account.id))
    i.save_trans.should == true

    i.approve!.should == true

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true
    i.pay_plans.unpaid.size.should == 1
    i.pay_plans.first.amount.should == i.balance

    d = Date.today

    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30, :interests_penalties => i.balance/10, :repeat => "1")

    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.unpaid.size.should == (i.balance/30).ceil
    
    i.pay_plans[0].interests_penalties.should == (i.balance/10).round(2)
    i.pay_plans[1].interests_penalties.should == ((i.balance - 30)/10).round(2)
    i.pay_plans[2].interests_penalties.should == ((i.balance - 60)/10).round(2)

    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # edit pay_plan
    pp = i.pay_plans[1]
    pp_last = i.pay_plans.last
    amt = pp_last.amount + pp.amount
    int = pp_last.interests_penalties + pp.interests_penalties
    i.edit_pay_plan(pp.id, :payment_date => pp.payment_date, :alert_date => pp.alert_date,
                    :amount => amt , :interests_penalties => int)
    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.unpaid.size.should == (i.balance/30).floor
    i.pay_plans[1].id.should == pp.id
    i.pay_plans[1].amount.should == amt
    
    # edit second pay_plan and repeat pattern
    pp = i.pay_plans[1]
    
    #puts "Before"
    #i.pay_plans.each {|pp| puts "#{pp.id} #{pp.amount} #{pp.interests_penalties}" }
    i.edit_pay_plan(pp.id, :payment_date => pp.payment_date, :alert_date => pp.alert_date,
                    :amount => 60, :interests_penalties => 50, :repeat => true)
    i.save_pay_plan.should == true
    i.reload
    i.pay_plans.size.should == ( (i.balance - 30)/60 ).ceil + 1

    i.pay_plans[1].interests_penalties.should == 50
    int_per = 50/( i.balance - i.pay_plans[0].amount )
    i.pay_plans[2].interests_penalties.should == (int_per * (i.balance - 90) ).round(2)
    #puts "After"
    #i.pay_plans.each {|pp| puts "#{pp.id} #{pp.amount} #{pp.interests_penalties}" }
  end

  scenario "Make payment with a contact account" do
    i = Income.new(income_params.merge(:account_id => client_account.id))
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    p = i.new_payment(:account_id => client_account.id, :exchange_rate => 1, :reference => 'Test for client')
    p.amount.should == i.balance
    i.save_payment.should == false
    i.reload

    p.account.cur(1).amount.should == 0

    # Make a deposit
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :to_id => client_account.id, :amount => i.balance, :reference => "Check 1120012" )
    al.save.should == true
    al.conciliate_account.should == true

    i.reload
    p = i.new_payment(:account_id => client_account.id, :exchange_rate => 1, :reference => 'Test for client')

    client_account.reload.cur(1).amount.should == -i.balance

    i.save_payment.should == true
    i.balance.should == 0

    p.account.cur(1).amount.should == 0
  end

  scenario "Make payment with a contact account and with different currency" do
    i = Income.new(income_params.merge(:account_id => client_account.id))
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true

    d = Date.today
    i.new_pay_plan(:amount => 30, :repeat => true, :payment_date => d, :alert_date => d - 5.days)
    i.save_pay_plan.should == true
    i.pay_plans.size.should == (i.balance/30).ceil

    # bank creation and client deposits in another currency
    new_bank = create_bank(:currency_id => 2)
    new_bank_account = new_bank.account
    new_bank_account.amount.should == 0
    al = AccountLedger.new_money(:operation => 'in', :account_id => new_bank_account.id, :to_id => client_account.id, :amount => 200, :reference => "Other currency check")

    client_account.cur(2).amount.should == 0

    al.save.should == true
    al.conciliate_account.should == true

    new_bank_account.reload
    new_bank_account.amount.should == 200
    client_account.reload.cur(2).amount.should == -200

    p = i.new_payment(:account_id => client_account.id, :amount => 30,
                 :exchange_rate => 0.5, :currency_id => 2, :reference => 'Last check')
    i.save_payment.should == true

    income_account = Account.org.find_by_original_type("Income")

    i.balance.should == i.total - 30
    
    client_account.reload

    p.conciliation.should == true

    client_account.reload
    income_account.reload

    client_account.cur(2).amount.should == -200 + 15
    income_account.cur(2).amount.should == -15

    i.reload
    i.pay_plans.unpaid.size.should == ( (i.total - 30)/30 ).ceil
    i.pay_plans.paid.size.should == 1
    i.pay_plans_total.should == i.total - 30
  end
end
