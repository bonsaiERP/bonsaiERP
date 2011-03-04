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

def pay_plan_params(options)
  d = options[:payment_date] || Date.today
  {:alert_date => (d - 5.days), :payment_date => d,
   :interests_penalties => 0,
   :ctype => 'Income', :description => 'Prueba de vida!', 
   :email => true }.merge(options)
end

feature "Income", "test features" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    
    Bank.destroy_all()
    Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 0) {|a| a.id = 1 }

    CashRegister.destroy_all()
    CashRegister.create!(:name => 'Cash register Bs.', :amount => 0, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}

    Contact.destroy_all
    Contact.create!(:name => 'karina', :matchcode => 'karina', :address => 'Mallasa') {|c| c.id = 1 }
  end

  scenario "Create a payment with nearest pay_plan" do
    ref_num = Income.last.ref_number
    i = Income.new(income_params)

    i.save.should == true
    pp = i.create_pay_plan(pay_plan_params(:amount => 100, :interests_penalties => 10))

    i = Income.find(i.id)
    i.pay_plans.unpaid.size.should == 2
    i.balance.should == i.pay_plans_total

    p = i.new_payment(:account_id => 1, :reference => 'NA')
    p.class.should == Payment

    p.amount.should == 100
    p.interests_penalties.should == 10

    p.save.should == true
    p.state.should == 'conciliation'

    al1 = p.account_ledger

    i = Income.find(i.id)
  
    i.balance.should == i.total
    i.pay_plans.unpaid.size.should == 2

    p = i.new_payment(:account_id => 1, :reference => '232322')
    p.class.should == Payment

    p.amount.should == i.pay_plans.unpaid.first.amount
    p.save.should == true

    al2 = p.account_ledger

    al1.conciliate_account.should == true
    al1.conciliation.should == true

    p_id = al1.payment.id
    Payment.find(p_id).state.should == 'paid'

    i = Income.find(i.id)
    i.balance.should_not == i.total
    i.balance.should == i.total - 100
    #i.pay_plans.unpaid.size.should == 1
    # Concilication
  end

#  scenario "Pay a cash transaction" do
#    i = Income.create!(income_params)
#    i.aprove!
#    i = Income.find(i.id)
#    i.state.should == "aproved"
#    Contact.find(1).client.should == true # Check that is client now
#    p = i.new_payment(:account_id => 1)
#
#    p.amount.should == i.balance
#    p.save!
#    i = Income.find(i.id)
#    i.balance.should == 0
#    i.state.should == 'paid'
#  end
#
#  scenario "Pay cash and set a differen amount in payment" do
#    i = Income.create!(income_params)
#    i.aprove!
#    i = Income.find(i.id)
#    i.state.should == "aproved"
#    p = i.new_payment(:account_id => 1, :amount => 10)
#
#    p.amount.should_not == i.balance
#    p.save!
#    p.amount.should == i.balance
#    
#    i = Income.find(i.id)
#    i.balance.should == 0
#    i.state.should == 'paid'
#  end
#
#  scenario "Pay a credit transaction" do
#    i = Income.create!(income_params)
#    # Fist PayPlan
#    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :amount => 100, :interests_penalties => 10))
#    pp.save
#
#    pp1_id = pp.id
#    i = Income.find(i.id)
#    i.payment_date.should == pp.payment_date
#
#    last_pay_date = Date.today + 20.days
#    # Second PayPlan
#    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => last_pay_date))
#    pp.amount.should == (i.balance - 100)
#    pp.save
#    i = Income.find(i.id)
#    i.payment_date.should_not == pp.payment_date
#    pp2_id = pp.id
#
#    i = Income.find(i.id)
#    i.pay_plans.size.should == 2
#    i.pay_plans.first.amount.should == 100
#    i.pay_plans.last.amount.should == ( i.balance - 100 )
#    i.aprove!
#
#    i.real_state.should == 'aproved'
#
#    # First payment
#    old_balance = i.balance
#    p = i.new_payment(:account_id => 1)
#    p.amount.should == 100
#
#    p.save.should == true
#
#    p.updated_pay_plan_ids.should == [pp1_id]
#    i = Income.find(i.id)
#    i.payment_date.should == last_pay_date
#
#    # Check for account_ledger
#    p.account_ledgers.first.class.should == AccountLedger
#    p.account_ledgers.first.amount.should == p.amount + p.interests_penalties
#
#    i = Income.find(i.id)
#
#    i = Income.find(i.id)
#    pp = i.pay_plans.first
#    pp = PayPlan.find(pp.id)
#    
#    pp.paid.should == true
#
#    i.balance.should == (old_balance - 100)
#    i.state.should == "aproved"
#
#    # payments
#    p = i.new_payment(:account_id => 1)
#    p.amount.should == (old_balance - 100)
# 
#    p.save.should == true
#    p.updated_pay_plan_ids.should == [pp2_id]
#    
#    i = Income.find(i.id)
#    i.state.should == "paid"
#    
#    i.balance.should == 0
#    
# 
#    # Nulling last payment should not allow
#    p.null_payment
#    i = Income.find(i.id)
#    i.state.should == "paid"
#  end
#
#  scenario "Pay a credit transaction with a higher amount" do
#    i = Income.create!(income_params)
#    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :amount => 100, :interests_penalties => 10))
#    pp.save
#    pp1_id = pp.id
#
#    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 20.days))
#    pp.amount.should == (i.balance - 100)
#    pp.save
#    pp2_id = pp.id
#
#    i = Income.find(i.id)
#    i.aprove!
#
#    # First payment
#    old_balance = i.balance
#    p = i.new_payment(:account_id => 1)
#    p.amount = 200
#    p.interests_penalties = 0
#    p.save
#    p.pay_plan.class.should == PayPlan
#    p.pay_plan.amount.should == (i.total - 200)
#    p.updated_pay_plan_ids.should == [pp1_id, pp2_id]
#    
#    # Check for account_ledger
#    p.account_ledgers.first.class.should == AccountLedger
#    p.account_ledgers.first.amount.should == p.amount
#    
#    i = Income.find(i.id)
#    i.pay_plans.unpaid.size.should == 1
#    pp = i.pay_plans.unpaid.first
#
#    pp.amount.should == (old_balance - 200)
#    pp.interests_penalties.should == 10
#  end
#
#  scenario "Pay a credit transaction and null payment" do
#    i = Income.create!(income_params)
#    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :amount => 100, :interests_penalties => 10))
#    pp.save
#    pp1_id = pp.id
#
#    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 20.days))
#    pp.amount.should == (i.balance - 100)
#    pp.save
#    pp2_id = pp.id
#
#    i = Income.find(i.id)
#    i.aprove!
#    old_balance = i.balance
#    # First payment
#    p = i.new_payment(:account_id => 1)
#    p.save
#    p.null_payment
#    p.account_ledgers.size.should == 2
#    p.account_ledgers.last.amount.should == -(p.amount + p.interests_penalties)
#    i = Income.find(i.id)
#    i.balance.should == old_balance
#  end
#
#  scenario "Pay with another currency" do
#    @params = income_params.merge(:discount => 0)
#    i = Income.new(@params)
#    total = @params[:transaction_details_attributes].inject(0) {|s, v| s+= v["price"] * v["quantity"] } 
#    total = total
#    total_cur = total / 2
#
#    i.currency_id = 2
#    i.currency_exchange_rate = 2
#    i.save
#    
#    i.total.should == total
#    i.total_currency.should == total_cur
#    i.balance.should == total_cur
#
#    pp = PayPlan.new(:transaction_id => i.id, :ctype => i.type )
#    pp.amount.should == total_cur
#  end
#
#  scenario "Change the state of a income when changing pay_plans" do
#    @params = income_params.merge(:discount => 0)
#    i = Income.new(@params)
#    i.save
#    
#    pp = i.new_pay_plan(:amount => 100)
#    pp.save
#    pp.amount.should == 100
#    i.aprove!
#
#    i.real_state.should == 'aproved'
#
#    pp = i.new_pay_plan(:payment_date => 5.days.ago)
#
#    pp.save.should == true
#    Income.find(i.id).real_state.should == 'due'
#
#  end
#
end
