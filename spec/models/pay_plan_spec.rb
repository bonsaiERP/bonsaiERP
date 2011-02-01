require 'spec_helper'

describe PayPlan do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
    d = Date.today
    
    @params = { :alert_date => (d - 5.days), :payment_date => d,
     :amount => 100, :interests_penalties => 0,
     :ctype => 'Income', :description => 'Prueba de vida!', 
     :email => true, :transaction_id => 1}
  end


  it 'should not allow pay_plans total greater transaction.total' do
    p2 = @params.merge(:amount => 200)

  end

  # Creates a transaction for payment
  def create_transaction
    d = Date.today + 1.day
    
    params = {"active"=>nil, "bill_number"=>"56498797", "contact_id"=>1, 
      "currency_exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
      "description"=>"Esto es una prueba", "discount"=>3, "project_id"=>1, 
      "ref_number"=>"987654"
    }
    details = [
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>15.5, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>10, "quantity"=> 20}
    ]
    params[:transaction_details_attributes] = details
    Transaction.create(params)
  end

  it 'should create an instance' do
    t = create_transaction
    params = @params.merge(:transaction_id => t.id)

    PayPlan.create!(params)
  end

  it 'should create 2 instances' do
    t = create_transaction
    params = @params.merge(:transaction_id => t.id)

    PayPlan.create!(params)
    
    PayPlan.create!(params)
  end

  # NOT test unit
  it 'should update transaction payment_date' do
    transaction = create_transaction

    d = transaction.payment_date - 1.day
    params = @params.merge(:transaction_id => transaction.id, :payment_date => d )
    pp = PayPlan.create(params)
    pp.transaction.should == transaction

    pp.transaction.payment_date.should == params[:payment_date]

    new_date = Date.today - 10.days
    params = @params.merge(:transaction_id => transaction.id, :payment_date => new_date)

    pp = PayPlan.create(params)
    pp.transaction.payment_date.should == pp.payment_date

    new_date = Date.today - 4.days
    params = @params.merge(:transaction_id => transaction.id, :payment_date => new_date)
    # Not nearest date
    pp = PayPlan.create(params)
    pp.transaction.payment_date.should_not == pp.payment_date

  end

  # Not a unit test
  it 'should change transaction to credit' do
    transaction = create_transaction
    transaction.cash.should == true
    
    params = @params.merge(:transaction_id => transaction.id)
    pp = PayPlan.create!( params )
    pp.transaction.cash.should == false
  end

  it 'should not allow a greater amount than the transaction balance' do
    transaction = create_transaction
    #puts transaction.pay_plans_total
    pp = PayPlan.create(@params.merge(:transaction_id => transaction.id, :amount => transaction.balance + 100))

    puts PayPlan.find(pp.id).attributes

    pp.save.should == false

    pp.errors[:amount].should_not == blank?
  end

  it 'should create a tra' do
    t = create_transaction
    t.cash = false
    t.save
    Transaction.find(t.id).cash.should == false
  end
end
