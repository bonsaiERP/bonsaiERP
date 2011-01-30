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

  it 'should create an instance' do
    PayPlan.any_instance.stubs(:transaction => Transaction.new(:currency_id => 1))
    PayPlan.create!(@params)
  end

  it 'should not allow pay_plans total greater transaction.total' do
    p2 = @params.merge(:amount => 200)
  end

end
