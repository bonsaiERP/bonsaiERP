require 'spec_helper'

describe Cash do
  let(:currency) { create :currency }
  let(:valid_params) { {:currency_id => currency.id, :name => 'Caja 1', :number => '12365498', :address => 'Uno'} }
  before(:each) do
    OrganisationSession.set(build(:organisation, currency: currency))
  end


  it { should_not have_valid(:name).when('No') }
  it { should have_valid(:currency_id).when(1) }

  it 'should create an instance' do
    c = Cash.create!(valid_params)
  end

  it 'should assisn amount to cash' do
    c = Cash.create!(valid_params.merge(amount: 200))

    c.account_amount.should == 200
    c.account_currency_id.should eq(currency.id)
    c.account_name.should == c.to_s
    c.account.original_type.should eq("Cash")
  end
end


