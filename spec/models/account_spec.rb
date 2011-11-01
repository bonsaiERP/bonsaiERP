# encoding: utf-8
require 'spec_helper'

describe Account do

  before :each do
    OrganisationSession.set(:id => 1, :currency_id => 1)
    UserSession.current_user = User.new {|u| u.id = 1 }

    #AccountType.create(:name => 'capital') {|a| a.id = 1}
    #AccountType.create(:name => 'products/services') {|a| a.id = 2}
  end

  let(:valid_params) { {:name => 'account1', :currency_id => 1 } }

  describe "Validations" do
    it { should have_valid(:name).when("a") }
    it { should_not have_valid(:name).when(" ", nil) }
  end

  it 'should create an Account' do
    a = Account.new(valid_params) {|a| a.amount = 100 }
    a.should_not be_valid
  end
  
  it 'should be valid' do
    a = Account.new(valid_params)
    a.amount = 100
    a.stub!(:currency => mock_model(Currency))
    a.should be_valid
  end

  it 'should be valid' do
    a = Account.new(valid_params)
    a.amount = 100
    a.stub!(:currency => nil)

    a.should_not be_valid
    a.errors[:currency].should_not be_blank
  end

end
