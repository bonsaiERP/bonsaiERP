require 'spec_helper'

describe User do

  it { should have_many(:links) }
  it { should have_many(:active_links) }
  it { should have_many(:links) }

  before(:each) do
  end

  let(:valid_attributes)do
    {email: 'demo@example.com', password: 'demo1234'}
  end

  it 'should not create' do
    expect{ User.create!(params)}.to raise_error
  end

  it 'should assign a token' do
  end

  it 'confirm registration' do
    u = User.new(email: "user@mail.com", password: "demo123")
    u.save_user.should be_true
    u.confirmed_at.should be_blank
    
    u.confirm_registration.should be_true
    u.should be_confirmed_registration
    u.confirmed_at.should_not be_blank
  end

end
