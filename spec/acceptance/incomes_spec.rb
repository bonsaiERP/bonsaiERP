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

  scenario "Create a payment with nearest pay_plan" do
    i = Income.new(income_params)

    i.save.should == true
    pp = i.create_pay_plan(pay_plan_params(:amount => 100))

    i = Income.find(i.id)
    i.pay_plans.unpaid.size.should == 2
    i.pay_plans.map(&:operation).uniq.should == ["in"]
    i.balance.should == i.pay_plans_total

    i.approve!
    #i.pay_plans.unpaid.each{|pp| puts "#{pp.amount}"} ###

    # FIRS Bank payment
    p = i.new_payment(:account_id => 1, :reference => '54654654654', :date => Date.today)

    p.class.should == Payment
    p.amount.should == 100.0
    p.paid?.should == false

    p.amount.should == 100

    p.save.should == true
    p.state.should == 'conciliation'
    p.paid?.should == false

    p = Payment.find(p.id)
    p.state.should == 'conciliation'

    al1 = p.account_ledger

    i = Income.find(i.id)
    i.payments.first.state.should_not == 'paid'


    i.balance.should == (i.total - 100)
    i.pay_plans.unpaid.size.should == 1


    # SECOND Cash payment
    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => Date.today + 2.days)
    
    p.amount.should == i.balance

    p.save.should == true

    p.state.should == 'paid'
    al2 = p.account_ledger #AccountLedger.find_by_payment_id(p.id)
    al2.class.should == AccountLedger
    al2.conciliation.should == true

    i = Income.find(i.id)
    i.balance.should_not == i.total

    al1.conciliate_account.should == true
    al1.conciliation.should == true


    p_id = al1.payment.id
    p = Payment.find(p_id)
    p.state.should == 'paid'

    i = Income.find(i.id)
    i.balance.should == 0

    i.pay_plans.unpaid.size.should == 0
  end

  scenario "Pay many pay_plans at the same time" do
    d = Date.today
    i = Income.new(income_params.merge(:date => d))
    
    i.save.should == true
    bal = i.balance

    pp = i.create_pay_plan(pay_plan_params(:amount => 100, :payment_date => d, :repeat => true))
    i = Income.find(i.id)
    #i.pay_plans.unpaid.each{|pp| puts "#{pp.amount} #{pp.payment_date}"} ###

    i.pay_plans.unpaid.size.should == 4
    i.pay_plans.unpaid[0].payment_date.should == d
    i.pay_plans.unpaid[0].alert_date.should == d - 5.days
    i.pay_plans.unpaid[1].payment_date.should == d + 1.month

    # UPDATE the first pay_plan date
    pp_id = i.pay_plans.first.id
    pdate = i.pay_plans.first.payment_date - 5.days
    adate =  i.pay_plans.first.alert_date - 5.days

    i.pay_plans.unpaid.first.payment_date.should_not == pdate

    i.update_pay_plan(:id => pp_id, :payment_date => pdate, :alert_date => adate)
    i = Income.find(i.id)

    i.pay_plans.unpaid.first.payment_date.should == pdate
    

    # PayPlan date for payment
    pdate = i.pay_plans.unpaid[1].payment_date
    adate =  i.pay_plans.unpaid[1].alert_date

    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d, :amount => 150)
    
    p.amount.should == 150
    p.save.should == true

    i = Income.find(i.id)
    i.payment_date.should == i.pay_plans.unpaid.first.payment_date

    i.balance.should == bal - 150
    i.balance.should == i.pay_plans_total
  end

  scenario "Destroy a payment when destroying account_ledger" do

    d = Date.today
    i = Income.new(income_params.merge(:date => d))
    
    i.save.should == true
    bal = i.balance

    pp = i.create_pay_plan(pay_plan_params(:amount => 100, :payment_date => d, :repeat => true))
    i = Income.find(i.id)

    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d, :amount => 150)
    
    p.amount.should == 150
    p.save.should == true
    i.payments.size.should == 1

    pid = p.id
    al = p.account_ledger
    #ac_id = p.account_ledger.account_id
    #ac_amount = p.account_ledger.account.total_amount

    al.destroy
    al.destroyed?.should == true
    #
    #al.payment(true).active.should == false
    #puts ac_amount
    #puts Account.find(ac_id).total_amount

    i.reload
    i.payments.size.should == 0
  end

  scenario "Modify payments and check that balance stays" do
    d = Date.today
    i = Income.new(income_params.merge(:date => d))
    
    i.save.should == true
    i = Income.find(i.id)
    i.approve!.should == true

    i.payment_date.should == d

    pp = i.create_pay_plan(pay_plan_params(:amount => 100, :payment_date => d, :repeat => true))

    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d)
    p.save.should == true

    i = Income.find(i.id)
    i.balance.should == i.total_currency - 100
    
    # Update pay_plan
    pid = i.pay_plans.unpaid.first.id
    i.update_pay_plan(:id => pid, :amount => 120)

    i = Income.find(i.id)
    i.pay_plans.unpaid.first.amount.should == 120
    # One aplied with payment
    i.pay_plans.unpaid.size.should == 3
    i.balance.should == i.total_currency - 100

    # Destroy pay_plan
    i.destroy_pay_plan(pid)
    i = Income.find(i.id)

    i.pay_plans.unpaid.size.should == 2
    i.balance.should == i.total_currency - 100
    i.pay_plans_total == i.balance

    # Create pay_plan
    i.create_pay_plan(:payment_date => Date.today - 1.day, :amount => 50)
    i = Income.find(i.id)

    i.pay_plans.unpaid.size.should == 3
    i.balance.should == i.total_currency - 100
    i.pay_plans_total == i.balance

    # Create repeated
    d = Date.today - 2.days
    i.create_pay_plan(:payment_date => d, :amount => 50, :repeat => true)
    i = Income.find(i.id)

    #i.pay_plans.unpaid.each {|v| puts v.amount }
    i.pay_plans.unpaid[0].amount.should == 50
    i.pay_plans.unpaid[0].payment_date.should == d
    i.pay_plans.unpaid[1].amount.should == 50
    i.pay_plans.unpaid[1].payment_date.should == d + 1.month
    i.pay_plans.unpaid[2].amount.should == 50
    i.pay_plans.unpaid[2].payment_date.should == d + 2.months
    
    i.balance.should == i.total_currency - 100

    # Update third with repeat
    pid = i.pay_plans.unpaid[2].id
    i.update_pay_plan(:id => pid, :amount => 30, :repeat => true)
    i = Income.find(i.id)

    
    i.pay_plans.unpaid[2].amount.should == 30
    i.pay_plans.unpaid[3].amount.should == 30

    i.balance.should == i.total_currency - 100
  end

  scenario 'test with different exchange_rates' do
    c =  Currency.first

    d = Date.today
    i = Income.new(income_params.merge(:date => d, :currency_id => 2, :currency_exchange_rate => 7))

    i.save.should == true
    i = Income.find(i.id)
    balance = i.balance

    i.currency_exchange_rate.should == 7
    i.balance.should == (i.total/7).round(2)
    
    pp = i.create_pay_plan(pay_plan_params(:amount => 20, :payment_date => d, :repeat => true))
    i = Income.find(i.id)

    
    i.pay_plans[0].amount.should == 20
    i.pay_plans[1].amount.should == 20
    i.pay_plans[2].amount.should == balance - 40
    
    # FIRST Payment
    p = i.new_payment(:account_id => 3, :reference => 'NA', :date => d)
    p.currency_id.should == 2
    p.amount.should == 20

    p.save.should == true
    p.account_ledger.currency_id.should == 2
    p.account_ledger.amount.should == 20
    i = Income.find(i.id)

    i.balance.should == balance - 20
    i.pay_plans.unpaid.size.should == 2

    # SECOND Payment
    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d, :currency_id => 1, :amount => 20, :exchange_rate => 7)

    p.save.should == true
    p.account_ledger.currency_id.should == 1
    p.account_ledger.description.downcase.should =~ /1 dolar = 7,0000 bolivianos/
    p.account_ledger.amount.should == 20 * 7

    i = Income.find(i.id)

    i.balance.should == balance - 40
    i.pay_plans.unpaid.size.should == 1

    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d, :currency_id => 1, :amount => 1, :exchange_rate => 7)

    p.save.should == true
    p.account_ledger.currency_id.should == 1
    i = Income.find(i.id)

    i.balance.should == balance - 41
    i.pay_plans.unpaid.first.amount.should == i.balance
    i.pay_plans.unpaid.size.should == 1
       
    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d, :currency_id => 2, :exchange_rate => 7)

    p.save.should == true
    i = Income.find(i.id)

    i.balance.should == 0
    i.pay_plans.unpaid.size.should == 0
    i.state.should == 'paid'
  end

  scenario 'delete payments' do
    c =  Currency.first

    d = Date.today
    i = Income.new(income_params.merge(:date => d, :currency_id => 2, :currency_exchange_rate => 7))

    i.save.should == true
    i.approve!
    i = Income.find(i.id)
    i.state.should == 'approved'

    balance = i.balance

    i.payment_date.should == d

    i.currency_exchange_rate.should == 7
    i.balance.should == (i.total/7).round(2)
    
    pp = i.create_pay_plan(pay_plan_params(:amount => 20, :payment_date => d, :repeat => true))
    i = Income.find(i.id)

    i.pay_plans[0].amount.should == 20
    i.pay_plans[1].amount.should == 20
    i.pay_plans[2].amount.should == balance - 40
    
    # FIRST Payment
    p = i.new_payment(:account_id => 3, :reference => 'NA', :date => d)
    p.currency_id.should == 2
    p.amount.should == 20

    p.save.should == true
    p.state.should == 'paid'
    p.account_ledger.currency_id.should == 2
    p.account_ledger.amount.should == 20
    p.account_ledger.conciliation.should == true

    i.reload

    i.balance.should == balance - 20
    i.pay_plans.unpaid.size.should == 2
    i.payment_date.should == i.pay_plans[1].payment_date

    # DELETE Payment
    puts i.pay_plans.size
    puts "--------------------------------"
    p.destroy
    i.reload
    puts ":::::::::::::::::::::"
    puts i.pay_plans.size
    puts i.balance

    i.balance.should == balance
    i.pay_plans_total.should == i.balance
    i.payment_date.should == i.pay_plans.unpaid.first.payment_date

    p.deleted_account_ledger_id.is_a?(Integer).should == true

    #i.payment_date.should == i.pay_plans[0].payment_date

    # SECOND Payment
    p = i.new_payment(:account_id => 2, :reference => 'NA', :date => d, :currency_id => 1, :amount => 20, :exchange_rate => 7)

    p.save.should == true
    p.account_ledger.currency_id.should == 1
    p.account_ledger.description.downcase.should =~ /1 dolar = 7,0000 bolivianos/
    p.account_ledger.amount.should == 20 * 7

    i = Income.find(i.id)

    i.balance.should == balance - 20
    i.pay_plans_total.should == i.balance

    # Thir
    p = i.new_payment(:account_id => 3, :reference => 'NA', :date => d, :currency_id => 1, :amount => i.balance)

    p.save.should == true
    p.account_ledger.currency_id.should == 2

    i = Income.find(i.id)

    i.balance.should == 0
    i.pay_plans.unpaid.size.should == 0
    i.state.should == 'paid'

    # DELETE to change state of transaction
    account = p.account_ledger.account
    p.destroy
    p.account_ledger.destroyed?.should == not(p.account_ledger.conciliation)

    p.account_ledger.id.should_not == p.account_ledger_created.id
    p.account_ledger.amount.should == -1 * p.account_ledger_created.amount

    account_total = account.total_amount
    account = Account.find(account.id)
    account.total_amount.should == account_total - p.account_ledger.amount


    i = Income.find(i.id)

    i.balance.should_not == 0
    i.pay_plans.unpaid.size.should == 1
    i.state.should_not == 'paid'
    i.state.should == 'approved'
  end

  scenario 'should update correctly pay_plans after payments are destroyed' do
    
    d = Date.today
    i = Income.new(income_params.merge(:date => d, :currency_id => 1))

    i.save.should == true
    i.approve!
    i = Income.find(i.id)
    i.state.should == 'approved'

    balance = i.balance
    
    # We must destroy the pay_plan to make it work
    pp = i.new_pay_plan(:amount => 20, :payment_date => d, :repeat => true)
    #pp.destroy
    pp = i.create_pay_plan(pay_plan_params(:amount => 20, :payment_date => d, :repeat => true) )

    i = Income.find(i.id)
    pps = i.pay_plans.size

    i.pay_plans_total.should == i.balance

    p = i.new_payment(:amount => 30, :reference => 'NA', :account_id => 1, :date => Date.today)
    p.save.should == true

    i = Income.find(i.id)

    i.total.should_not == i.balance
    i.pay_plans_total.should == i.balance
    i.balance.should == balance - 30

    p = i.new_payment(:amount => 20, :reference => 'NA', :account_id => 1, :date => Date.today)

    p.save.should == true
    p.account_ledger.account.class.should == Bank

    i = Income.find(i.id)
    i.balance.should == balance - 50
    bal = i.balance

    # Destroy a payment and check that the account_ledger is deleted because it's not conciliated
    al_id = p.account_ledger.id
    p.destroy
    i = Income.find(i.id)

    #AccountLedger.where(:id => al_id).size.should == 0
    i.balance.should == balance - 30
  end

  scenario 'should conciliate the correct sum with payments' do
    d = Date.today
    i = Income.new(income_params.merge(:date => d, :currency_id => 1))

    i.save.should == true
    i.approve!
    i = Income.find(i.id)
    i.state.should == 'approved'

    balance = i.balance
    
    # We must destroy the pay_plan to make it work
    pp = i.new_pay_plan(:amount => 20, :payment_date => d, :repeat => true)
    #pp.destroy
    pp = i.create_pay_plan(pay_plan_params(:amount => 20, :payment_date => d, :repeat => true) )

    i = Income.find(i.id)
    pps = i.pay_plans.size

    i.pay_plans_total.should == i.balance

    balance = i.balance

    p = i.new_payment(:amount => 30, :reference => 'NA', :account_id => 1, :date => Date.today)
    p.save.should == true

    i = Income.find(i.id) 
   
    i.balance.should == balance - 30
    p.account_ledger.conciliate_account
    i = Income.find(i.id)
    i.balance.should == balance - 30
    
  end

  scenario 'payments with interests' do
    d = Date.today
    i = Income.new(income_params.merge(:date => d, :currency_id => 1))

    i.save.should == true
    i.approve!
    i.state.should == 'approved'
    #puts i.balance
    # 344.35
    #i = Income.find(i.id)
    #i.state.should == 'approved'

    #balance = i.balance
    #
    ## Create a new pay plan
    pp = i.create_pay_plan(pay_plan_params(:amount => 50, :interests_penalties => 33.44, :payment_date => d, :repeat => true) )

    pps = i.pay_plans.size

    i.pay_plans(true).unpaid.size.should == 7
    i.pay_plans.unpaid.first.interests_penalties.should == 33.44
    interests = i.pay_plans.unpaid.map(&:interests_penalties)

    i.reload
    i.balance.should == i.pay_plans_total
    #i.pay_plans.each {|pp| puts "#{pp.amount}  #{pp.interests_penalties} #{pp.paid}"}

    p = i.new_payment(:amount => 50, :reference => 'NA', :account_id => 1, :date => Date.today, :interests_penalties => 0)
    #puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    p.save.should == true

    i.pay_plans(true).unpaid.size.should == 6
    i.pay_plans.unpaid.first.interests_penalties.should == interests.slice(0,2).sum
    tot_int = interests[0] + interests[1]

    i.reload
    i.balance.should == i.pay_plans_total
    # 62.02 + 23.73 + 18.87

    # Create a new payment
    p = i.new_payment(:amount => 150, :reference => 'NA', :account_id => 1, :date => Date.today, :interests_penalties => 50)
    p.save.should == true

    i.pay_plans(true).unpaid.size.should == 3
    i.pay_plans.unpaid.first.interests_penalties.should == interests.slice(0,5).sum - 50
    i.pay_plans_total.should == i.reload.balance
    i.payments(true).size.should == 2

    i.reload
    i.balance.should == i.pay_plans_total
    #i.pay_plans(true).each {|pp| puts "#{pp.amount}  #{pp.interests_penalties} :: #{pp.paid}"}
    # Create a new payment and display error because the amount does not cover interests
    p = i.new_payment(:amount => i.balance, :reference => 'NA', :account_id => 1, :date => Date.today, :interests_penalties => 0)
    p.save.should_not == true
    p.errors[:base].should_not == blank?
    
    i.pay_plans(true).unpaid.size.should == 3

    i.payments(true).size.should == 2
  end


  scenario 'create a payment with interests' do
    d = Date.today
    i = Income.new(income_params.merge(:date => d, :currency_id => 1, :contact_id => 1))

    i.save.should == true
    #puts i.balance
    # 344.35
    
    pp = i.create_pay_plan(pay_plan_params(:amount => 200, :interests_penalties => 50, :payment_date => d) )
    pps = i.pay_plans.size

    #i.pay_plans.each { |pp| puts "#{ pp.amount } :: #{ pp.interests_penalties }" }

    i.pay_plans.size.should == 2
    i.pay_plans(true).unpaid.size.should == 2
    i.balance.should == i.pay_plans_total
    
    i.approve!
    i.state.should == 'approved'

    i.reload
    p = i.new_payment(:account_id => 1, :date => d, :reference => 'NA')

    p.amount.should == 200
    p.interests_penalties.should == 50

    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    p.save.should == true
    p.account_ledger.amount.should == 250

    i.pay_plans(true).size.should == 2
  end
end
