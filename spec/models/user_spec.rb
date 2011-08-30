require 'spec_helper'

describe User do

  before(:each) do
    RegistrationMailer.stubs(:send_registration => stub(:deliver => true))
  end

  let(:valid_params)do
    {:email => 'demo@example.com', :password => 'demo123'}
  end

  it 'should create' do
    User.create!(valid_params)
  end

  it 'should assign a token' do
    u = User.create!(valid_params)
    u.confirmation_token.size == 12
    u.confirmation_sent_at.class.to_s == "DateTime"
  end

  it 'should conirm the token' do
    u = User.create!(valid_params)
    u.confirmated?.should be_false
    
    u.confirm_token(u.confirmation_token).should == true
    u.confirmated?.should be_true
  end


  it 'should conirm the token' do
    u = User.create!(valid_params)
    u.links.should have(0).elements
  end

  it 'should return false if confirmed' do
    u = User.create!(valid_params)
    u.confirmated?.should be_false
    
    u.confirm_token(u.confirmation_token).should be_true
    u.confirm_token(u.confirmation_token).should be_false
  end
end
