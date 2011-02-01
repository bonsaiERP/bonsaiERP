# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

def income_params
    d = Date.today
    @income_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id"=>1, 
      "currency_exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount"=>3, "project_id"=>1, 
      "ref_number"=>"987654"
    }
    details = [
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>15.5, "quantity"=> 10},
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
   :email => true, :transaction_id => 1}.merge(options)
end

feature "PayPlan", "sets cash and payment_date for Income" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
  end

  scenario "Update Income cash" do
    i = Income.create!(income_params)
    i.cash.should == true

    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 10.days, :amount => 100))
    pp.save

    i = Income.find(i.id)
    i.pay_plans.size.should == 1

    # cash
    i.cash.should == false
    #payment_date
    i.date.should_not == pp.payment_date
    i.payment_date.should == pp.payment_date
    
  end

  scenario "Add new payment with more advanced date" do
    i = Income.create!(income_params)

    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 5.days, :amount => 100))
    pp.save
    i = Income.find(i.id)
    i.pay_plans.size.should == 1
    i.cash.should == false
    i.payment_date.should == pp.payment_date

    # Create a new pay plan with a date with 
    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 3.days, :amount => 100))
    pp.save
    i = Income.find(i.id)
    i.pay_plans.size.should == 2
    i.payment_date.should == pp.payment_date
  end

  scenario "Add and delete pay_plans" do
    i = Income.create!(income_params)

    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 5.days, :amount => 100))
    pp.save
    i = Income.find(i.id)
    i.pay_plans.size.should == 1
    i.cash.should == false
    i.payment_date.should == pp.payment_date

    # Create a new pay plan with a date with 
    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 3.days, :amount => 100))
    pp.save
    i = Income.find(i.id)
    i.pay_plans.size.should == 2
    i.payment_date.should == pp.payment_date

    i.pay_plans.destroy_all
    i = Income.find(i.id)
    i.pay_plans.size.should == 0
    i.cash.should == true
    i.date.should_not == pp.payment_date
  end

  scenario "allows payments with the balance, and denies with higher than balance" do
    i = Income.create!(income_params)
    balance = i.balance

    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 5.days, :amount => balance - 100))
    pp.save
    pp_id = pp.id
    i = Income.find(i.id)
    i.pay_plans.size.should == 1
    i.cash.should == false
    i.payment_date.should == pp.payment_date


    # Create a new pay plan with a date with 
    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 3.days, :amount => 100))
    pp.amount.should == 100
    pp.amount = 200
    pp.valid?.should == false
    pp.errors[:amount].should_not == blank?

    # Edit pay plan 
    pp = PayPlan.find(pp_id)
    pp.update_attributes(:amount => balance)
    i = Income.find(i.id)
    i.pay_plans_balance.should == 0

    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :payment_date => Date.today + 3.days, :amount => 0, :interests_penalties => 20))
    pp.save.should == true
  end

end

