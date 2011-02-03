require 'spec_helper'

describe Payment do
  before(:each) do
    OrganisationSession.stubs(:organisation_id => 1)
    @params = {:amount => 100, :date => Date.today}

    Transaction.any_instance.stubs(:balance => 50, :id => 1, :payment= => '')
  end

  it 'should not validate if amount greater than transaction balance' do
    p = Payment.new(@params.merge(:transaction_id => 1))
    p.stubs(:transaction => Transaction.new)
    p.valid?.should == false
    p.errors[:amount].should_not == blank?
  end

  it 'should not allow amount 0 or interests_penalties 0' do
    p = Payment.new(@params.merge(:transaction_id => 1, :amount => 0))
    p.stubs(:transaction => Transaction.new)
    p.valid?.should == false
    p.errors[:amount].should_not == blank?
    p.errors[:amount].should == ["Debe ingresar una cantidad mayor a 0 para Cantidad o Intereses/Penalidades"]
  end

end
