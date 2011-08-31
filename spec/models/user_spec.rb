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

  describe "new_user" do
    it 'should create and instance with email, password' do
      u = User.new_user("demo@example.com", "demo123")
      u.class.should == User

      u.email.should == "demo@example.com"
      u.password.should == "demo123"

      u.attributes.each do |k,v|
        v.should be_nil unless ["email", "password", "password_digest", "sign_in_count", "change_default_password"].include?(k)
      end
    end
  end

  describe "User with change_default_password = true" do
    subject { User.new{|u| u.change_default_password = true } }

    # abbrevation
    it{ should have_valid(:abbreviation).when("UN") }
    it{ should_not have_valid(:abbreviation).when("A") }
    # rolname
    it { should have_valid(:rolname).when("gerency")}
    it { should_not have_valid(:rolname).when("admin")}
    it { should_not have_valid(:rolname).when("pato")}
  end

  describe "New user with change_default_password = false" do
    subject { User.new }

    it {should_not be_change_default_password}
  end

end
