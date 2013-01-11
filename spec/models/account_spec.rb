# encoding: utf-8
require 'spec_helper'

describe Account do
  it { should have_valid(:currency).when('BOB', 'EUR') }
  it { should_not have_valid(:currency).when('BOBB', 'UUUU') }
  it { should have_valid(:amount).when(10, 0.0, -10.0) }
  it { should_not have_valid(:amount).when(nil, '') }

  before :each do
    UserSession.current_user = build :user, id: 1
  end

  let(:valid_params) do
    {name: 'account1', currency: 'BOB', amount: 100}
  end

  it 'should be created' do
    a = Account.create!(valid_params)

    a.should be_persisted
    a.initial_amount.should == 100
  end

end
