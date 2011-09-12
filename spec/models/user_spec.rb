require 'spec_helper'

describe User do

  before(:each) do
    RegistrationMailer.stubs(:send_registration => stub(:deliver => true))
  end

  let(:valid_params)do
    {:email => 'demo@example.com', :password => 'demo123'}
  end

  it 'should not create' do
    expect{ User.create!(params)}.to raise_error
  end

  it 'should create' do
    User.create!(valid_params) {|u| u.abbreviation = "NEW"}
  end

  it 'should assign a token' do
    u = User.create!(valid_params) {|u| u.abbreviation = "NEW"}
    u.confirmation_token.size == 12
    u.confirmation_sent_at.class.to_s == "DateTime"
    u.salt.should_not be_blank
  end

  it 'should conirm the token' do
    u = User.create!(valid_params) {|u| u.abbreviation = "NEW"}
    u.confirmated?.should be_false
    
    u.confirm_token(u.confirmation_token).should == true
    u.confirmated?.should be_true
  end


  it 'should conirm the token' do
    u = User.create!(valid_params) {|u| u.abbreviation = "NEW"}
    u.links.should have(0).elements
  end

  it 'should return false if confirmed' do
    u = User.create!(valid_params) {|u| u.abbreviation = "NEW"}
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
      u.abbreviation.should == "GEREN"

      u.save.should be_true
      u.abbreviation.should == User::ABBREV
    end

    it 'should not allow login unconfirmed accounts' do
      u = User.new_user("demo@example.com", "demo123")
      u.save.should be_true 
      
      u = User.find_by_email("demo@example.com")
      u.authenticate("demo123").should be_false
      u.errors[:base].should_not be_blank
    end

    it 'should authenticate confirmed user' do
      u = User.new_user("demo@example.com", "demo123")
      u.save.should be_true 
      u.confirm_token(u.confirmation_token).should be_true

      u = User.find_by_email("demo@example.com")
      u.authenticate("demo123").should == u
      u.authenticate("demo12").should be_false
    end

    it 'should use the salt for authentication' do
      u = User.new_user("demo@example.com", "demo123")
      u.save.should be_true
      u.confirmed_at.should be_nil

      u.confirm_token(u.confirmation_token).should be_true
      u.reload
      u.salt = "jojo"
      u.save
      u.reload
      u.salt.should == "jojo"

      u.authenticate("demo123").should be_false
    end
  end

  describe "User with change_default_password = true" do
    subject { User.new{|u| u.change_default_password = true } }

    # abbrevation
    it{ should have_valid(:abbreviation).when("UN") }
    it{ should_not have_valid(:abbreviation).when("A") }
    # rolname
    it { should have_valid(:rolname).when("gerency")}
    it { should_not have_valid(:rolname).when("admin") }
    it { should_not have_valid(:rolname).when("pato") }
  end

  describe "New user with change_default_password = false" do
    subject { User.new }

    it {should_not be_change_default_password}
  end

  describe "Update user" do
    let!(:user){ User.create!(valid_params) {|u| u.abbreviation = "NEW" } }

    it 'should update params' do
      user.update_attributes(:first_name => "New name", :last_name => "Other name").should be_true
      user.reload
      user.first_name.should == "New name"
      user.last_name.should == "Other name"
    end
  end
end
