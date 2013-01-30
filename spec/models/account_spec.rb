# encoding: utf-8
require 'spec_helper'

describe Account do
  it { should have_valid(:currency).when('BOB', 'EUR') }
  it { should_not have_valid(:currency).when('BOBB', 'UUUU') }
  it { should have_valid(:amount).when(10, 0.0, -10.0) }
  it { should_not have_valid(:amount).when(nil, '') }

  it { should validate_uniqueness_of(:name) }

  before :each do
    UserSession.user = build :user, id: 1
  end

  let(:valid_params) do
    {name: 'account1', currency: 'BOB', amount: 100, state: 'new'}
  end

  it 'should be created' do
    a = Account.create!(valid_params)
  end

end
