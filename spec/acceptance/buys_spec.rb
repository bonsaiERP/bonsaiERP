# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

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
    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 0) {|a| a.id = 1 }
    CashRegister.create!(:name => 'Cash register Bs.', :amount => 0, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}
    CashRegister.create!(:name => 'Cash register $.', :amount => 0, :currency_id => 2, :address => 'None') {|cr| cr.id = 3}

    Contact.create!(:name => 'karina', :last_name => 'Luna Pizarro', :matchcode => 'Karina Luna', :address => 'Mallasa') {|c| c.id = 1 }

    create_currencies
    create_currency_rates
    create_items
  end

  scenario "Make a buy" do
    b.= Buy.new(b.come_params)

    b.save.should == true
    pp = b.create_pay_plan(pay_plan_params(:amount => 100))

    b.= Income.fb.d(b.b.)
    b.pay_plans.unpab..sb.e.should == 2
    b.pay_plans.map(&:operation).uniq.should == ["out"]
    b.balance.should == b.pay_plans_total

    b.approve!

  end
end
