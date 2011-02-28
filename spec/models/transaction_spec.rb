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
  it 'should create a complete pay_plan balance' do
    t = Transaction.create(@params)
    d = Date.today
    pp = t.new_pay_plan(:amount => 100, :payment_date => d + 10.days)
    pp.save
    t.pay_plans.unpaid.size.should == 2
    t.pay_plans_total.should == t.balance
    t.pay_plans.last.payment_date.should == d + 11.days
  end

  it 'should update the last pay_plan' do
    t = Transaction.create(@params)
    pp = t.create_update_pay_plans(:amount => 100)
    pp.save

    pp = t.pay_plans.first
    d = Date.today
    pp.update_attributes(:payment_date => d + 10.days , :alert_date => d + 8.days)

    t = Transaction.find(t.id)
    t.pay_plans.last.payment_date.should == d + 10.days
    t.pay_plans.last.alert_date.should == d + 8.days
  end

  it 'should move update the date for the next payment' do
    d = Date.today
    t = Transaction.create(@params)
    pp = t.new_pay_plan(:amount => 100, :payment_date => d + 20.days, :alert_date => d + 10.days)
    pp.save
  end

end
