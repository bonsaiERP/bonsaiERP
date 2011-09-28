require 'spec_helper'

describe User do

  before(:each) do
    RegistrationMailer.stub!(:send_registration => stub(:deliver => true))
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

    it 'should allow password reset' do
      u = User.new_user("demo@example.com", "demo123")
      u.save.should be_true
      u.confirmed_at.should be_nil
      u.should_not be_change_default_password
      
      u.confirm_token(u.confirmation_token).should be_true

      u.reset_password_token.should be_blank
      u.reset_password_sent_at.should be_blank

      u.reset_password.should be_true
      u.reload

      u.reset_password_token.should_not be_blank
      u.reset_password_sent_at.should_not be_blank
    end
  end

  describe "User with change_default_password = true" do
    subject { User.new{|u| u.change_default_password = true } }

    # abbrevation
    it{ should have_valid(:abbreviation).when("UN") }
    it{ should_not have_valid(:abbreviation).when("A") }
    # rolname
    #it { should have_valid(:rolname).when("gerency")}
    #it { should_not have_valid(:rolname).when("admin") }
    #it { should_not have_valid(:rolname).when("pato") }
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

  describe "Add a company user" do
    let(:user_params) {
      {:email => 'other@example.com', :first_name => 'Other',
      :last_name => 'User', :abbreviation => 'OUS', :rolname => 'operations'}
    }

    let(:pass_params) {
      {:password => "demo123", :password_confirmation => "demo123",
      :old_password=> "demo123"}
    }

    before(:each) do
      OrganisationSession.set :id => 1
      RegistrationMailer.stub!(:send_registration => stub(:deliver => true))
    end

    it 'should add organisation user' do
      user = User.new
      user.add_company_user(user_params).should be_true

      user.should be_persisted
      user.confirmation_token.should_not be_blank
      user.should be_change_default_password

      user.links.should have(1).element
      link = user.links.first
      link.rol.should == 'operations'
      link.organisation_id.should == 1

      user.confirmed_at.should be_blank
      user.confirm_token(user.confirmation_token)
      user.confirmed_at.should_not be_blank
    end

    it 'should update the default password' do
      user = User.new

      user.add_company_user(user_params).should be_true
      user.should be_persisted
      user.should be_change_default_password

      user.confirm_token(user.confirmation_token).should be_true

      user.update_default_password(pass_params).should be_true
      user.should_not be_change_default_password
    end

    it 'should not update default password if doesn\'t match' do
      user = User.new

      user.add_company_user(user_params).should be_true
      user.should be_persisted
      user.should be_change_default_password

      user.confirm_token(user.confirmation_token).should be_true

      p_params = pass_params.dup.merge(:password_confirmation => "demo431")
      user.update_default_password(p_params).should be_false
      user.errors[:password].should_not be_blank
      user.should be_change_default_password
    end

    it 'should not update if the default_password is set' do
      user = User.new

      user.add_company_user(user_params).should be_true
      user.should be_persisted
      user.should be_change_default_password

      user.confirm_token(user.confirmation_token).should be_true

      p_params = pass_params.dup.merge(:old_password => user.temp_password)
      user.update_password(p_params).should be_false
    end
  end

  describe "Update password" do
    let(:pass_params) {
      {:password => "demo123", :password_confirmation => "demo123",
      :old_password=> "demo123"}
    }
    let(:user_params) {
      {:email => 'other@example.com', :first_name => 'Other',
      :last_name => 'User', :abbreviation => 'OUS', :rolname => 'operations'}
    }

    before(:each) do
      OrganisationSession.set :id => 1
      RegistrationMailer.stub!(:send_registration => stub(:deliver => true))
    end

    let!(:user) {
      user = User.new
      user.add_company_user(user_params)
      user.confirm_token(user.confirmation_token)
      user.update_default_password(pass_params)
      user
    }

    it 'should update password' do
      user.update_password(pass_params).should be_true
    end

    it 'should not update password if old_password doesn\'t match' do
      p_params = pass_params.dup.merge(:old_password => 'demo321')

      user.update_password(p_params).should be_false
      user.errors[:old_password].should_not be_blank
    end

    it 'should not update if password do not match' do
      p_params = pass_params.dup.merge(:password_confirmation => 'demo321')

      user.update_password(p_params).should be_false
      user.errors[:password].should_not be_blank
    end

    it 'should update the password with new one' do
      user.update_password(:old_password => 'demo123', :password => 'Demo123', :password_confirmation => 'Demo123').should be_true

      user.authenticate('demo123').should be_false
      user.authenticate('Demo123').should_not be_false

    end
  end
end
