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

feature "Transaction", "test features" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
  end

  scenario "Create a payment with nearest pay_plan" do
    i = Income.create!(income_params)
    pp = PayPlan.new(pay_plan_params(:transaction_id => i.id, :amount => 100, :interests_penalties => 10))
    pp.save

    i = Income.find(i.id)
    p = i.new_payment
    p.class.should == Payment

    p.amount.should == pp.amount
    p.interests_penalties.should == pp.interests_penalties
    
    pp2 = PayPlan.new(pay_plan_params(:transaction_id => i.id, :amount => 50, :interests_penalties => 5, :payment_date => Date.today + 5.days))

    i = Income.find(i.id)
    p = i.new_payment
    p.class.should == Payment

    p.amount.should == pp.amount
    p.interests_penalties.should == pp.interests_penalties

  end

  scenario "Pay a cash transaction" do

  end
end

