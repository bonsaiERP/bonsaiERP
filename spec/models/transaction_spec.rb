require 'spec_helper'

describe Transaction do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
    OrganisationSession.stubs(:id => 1)

    @params = {"active"=>nil, "bill_number"=>"56498797", "contact_id"=>1, 
      "currency_exchange_rate"=>1, "currency_id"=>1, "date"=>'2011-01-24', 
      "description"=>"Esto es una prueba", "discount"=>3, "project_id"=>1, 
      "ref_number"=>"987654"
    }
    @details = [
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>15.5, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>10, "quantity"=> 20}
    ]
    @params[:transaction_details_attributes] = @details
  end

  def set_transaction_taxes(*rates)
    rates = rates.any? ? rates : [13, 1.5]
    arr = []
    rates.each_with_index do |rate, i|
      arr << Object.new
      arr.last.stubs(:rate => rate, :id => i + 1)
    end
    @params["taxis_ids"] = arr.map(&:id)
    Tax.stubs(:find => arr)
    Transaction.any_instance.stubs(:taxes => arr)
  end

  it 'should have total and balance equal' do
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total.should == transaction.balance
  end

  # NOT unit test
  it 'should set the values of tax and discount if nil' do
    @params["discount"] = nil
    transaction = Transaction.new(@params)
    transaction.save
    transaction.discount.should == 0
    transaction.tax_percent.should == 0
  end

  # NOT unit test
  it 'should calculate total with discount and without taxes' do
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total.to_f.should == 344.35
  end

  it 'should calculate the gross total' do
    set_transaction_taxes
    transaction = Transaction.new(@params)
    transaction.save
    transaction.gross_total.to_f.should == 355
    transaction.gross_total.should_not == transaction.total
  end

  # NOT unit test
  it 'should calculate total with taxes and set balance' do
    set_transaction_taxes
    t = Transaction.new
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total.to_f.should == 394.28075
  end

  it 'should should store the total taxes percentage' do
    set_transaction_taxes
    transaction = Transaction.new(@params)
    transaction.save
    transaction.tax_percent.should == 14.5
  end

  it 'should calculate the taxes total' do
    set_transaction_taxes
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total_taxes.to_f.should == 49.93075
  end

  it 'should not present the currency' do
    transaction = Transaction.new(@params)
    transaction.save
    o = Object.new
    o.stubs(:id => 1)
    Organisation.stubs(:find => o)
    
    transaction.present_currency.to_s.should == ""
  end


  it 'should present the currency' do
    transaction = Transaction.new(@params)
    transaction.save
    o = Object.new
    o.stubs(:id => 2)
    Organisation.stubs(:find => o)
    cur = Object.new
    cur.stubs(:to_s => "Symbol Name")
    Transaction.any_instance.stubs(:currency => cur)
    
    transaction.present_currency.to_s.should == "Symbol Name"
  end

  # Returns an array ob stubed objects
  def create_stubs_array(array)
    arr = []
    array.each do |v|
      o = Object.new
      o.stubs(v)
      arr << o
    end
    arr
  end

  it 'should set the payment date' do
    transaction = Transaction.create(@params)

    transaction.payment_date.should == transaction.date
  end

  #####################################
  # Params to test pay_plan
  def pay_plan_params(params)
    d = Date.today
    params[:payment_date] = params[:date] || d
    params[:alert_date] = params[:date] || (d - 5.days)
    { :amount => 100, :interests_penalties => 0,
     :ctype => 'Income', :description => 'Prueba de vida!', 
     :email => true}.merge(params)
  end

  # Payments
  it 'should prepare a payment paymets or cash' do
    t = Transaction.create(@params)
    
    p = t.new_payment
    p.class.should == Payment
    p.amount.should == t.balance
    p.transaction_id.should == t.id
  end

  ##############################
  # PayPlans
  it 'should instance a new with the balance' do
    t = Transaction.create(@params)
    d = Date.today
    p = t.new_pay_plan
    p.amount.should == t.pay_plans_balance
    p.payment_date.should == d
  end
  
  #it 'should not allow a quantity greater than the balance' do
  #  t = Transaction.create(@params)
  #  d = Date.today
  #  
  #  p = t.new_pay_plan(:amount => t.balance + 10, :payment_date => d + 3.days)
  #  p.amount.should == t.balance + 10
  #  p.valid?.should == false
  #  p.errors[:amount].should_not == blank?
  #end

  it 'should create a complete pay_plan balance' do
    t = Transaction.create(@params)
    d = Date.today
    pp = t.create_pay_plan(:amount => 100, :payment_date => d + 10.days, :interests_penalties => 34.43)

    pp.class.should == PayPlan
    #pp.should == t.pay_plans.unpaid.first
    t = Transaction.find(t.id)

    t.pay_plans.unpaid.size.should == 4
    t.pay_plans_total.should == t.balance

  end

  it 'should create a complete pay_plan balance and update the list' do
    t = Transaction.create(@params)
    d = Date.today
    pp = t.create_pay_plan(:amount => 100, :payment_date => d + 10.days, :interests_penalties => 34.43)

    t = Transaction.find(t.id)
    t.pay_plans.unpaid.size.should == 4
    
    t.create_pay_plan(:amount => 200, :payment_date => d + 15.days)
    t = Transaction.find(t.id)

    #t.pay_plans.unpaid.each{|pp| puts "#{pp.id} #{pp.amount}"}
    t.pay_plans.size.should == 3
    t.pay_plans[0].amount.should == 100
    t.pay_plans[1].amount.should == 200
    t.pay_plans[2].amount.should == (t.balance - 300)
    t.pay_plans_total.should == t.balance
  end

  it 'should create a new pay_plan and delete all other if a new is created with repeat' do
    t = Transaction.create(@params)
    d = Date.today
    pp = t.create_pay_plan(:amount => 100, :payment_date => d + 10.days, :interests_penalties => 34.43)

    t = Transaction.find(t.id)
    t.pay_plans.unpaid.size.should == 4
    
    t.create_pay_plan(:amount => 50, :payment_date => d + 15.days, :repeat => true)
    t = Transaction.find(t.id)

    #t.pay_plans.unpaid.each{|pp| puts "#{pp.id} #{pp.amount} #{pp.payment_date}"}
    t.pay_plans_total.should == t.balance
    t.pay_plans[1].amount.should == 50
    d2 = d + 15.days
    t.pay_plans[1].payment_date.should == d2
    t.pay_plans[2].payment_date.should == d2 + 1.month
    t.pay_plans[3].payment_date.should == d2 + 2.months
    t.pay_plans[4].payment_date.should == d2 + 3.months
    t.pay_plans[5].payment_date.should == d2 + 4.months
  end

  it 'should update' do
    t = Transaction.create(@params)
    d = Date.today
    pp = t.create_pay_plan(:amount => 100, :payment_date => d + 10.days, :interests_penalties => 34.43)

    t = Transaction.find(t.id)
    pp = t.pay_plans.unpaid[1]
    puts "---------"
    t.update_pay_plan(:id => pp.id, :amount => 150)

    t = Transaction.find(t.id)
    t.pay_plans_total.should == t.balance
    t.pay_plans.unpaid[1].amount.should == 150
  end



end
