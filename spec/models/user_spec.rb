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

  it 'should assign a token' do
    u = User.new_user("user@mail.com", "demo123")
    u.save_user.should be_true

    u.confirmation_token.should_not be_blank
    u.confirmation_sent_at.class.to_s == "DateTime"
    u.salt.should_not be_blank
  end

  it 'should confirm the token' do
    u = User.new_user("user@mail.com", "demo123")
    u.save_user.should be_true
    
    u.confirm_token(u.confirmation_token).should == true
    u.confirmated?.should be_true
  end


  it 'should conirm the token' do
    u = User.new_user("user@mail.com", "demo123")
    u.save_user.should be_true
    
    u.links.should have(0).elements
  end

  it 'should return false if confirmed' do
    u = User.new_user("user@mail.com", "demo123")
    u.save_user.should be_true
    
    u.confirmated?.should be_false
    
    u.confirm_token(u.confirmation_token).should be_true
    u.confirm_token(u.confirmation_token).should be_true
  end

  ########################################
  describe "new_user" do

    it 'should not allow login unconfirmed accounts' do
      u = User.new_user("demo@example.com", "demo123")
      u.save_user.should be_true 
      
      u = User.find_by_email("demo@example.com")
      u.authenticate("demo123").should be_false
      u.errors[:base].should_not be_blank
    end

    it 'should authenticate confirmed user' do
      u = User.new_user("demo@example.com", "demo123")
      u.save_user.should be_true 
      u.confirm_token(u.confirmation_token).should be_true

      u = User.find_by_email("demo@example.com")
      u.authenticate("demo123").should == u
      u.authenticate("demo12").should be_false
    end

    it 'should use the salt for authentication' do
      u = User.new_user("demo@example.com", "demo123")
      u.save_user.should be_true
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
  ########################################

  ########################################
  describe "New user with change_default_password = false" do
    subject { User.new }

    it {should_not be_change_default_password}
  end
  ########################################

  ########################################
  describe "Add a company user" do
    let(:user_params) {
      {:email => 'other@example.com', :first_name => 'Other',
      :last_name => 'User', :rolname => 'operations'}
    }

    let(:pass_params) {
      {:password => "demo123", :password_confirmation => "demo123",
      :old_password=> "demo123"}
    }

    let!(:user) {
      u = User.new_user("demo@example.com", "Demo123")
      u.save_user.should be_true
      u
    }

    before(:each) do
      OrganisationSession.set :id => 1
      RegistrationMailer.stub!(:send_registration => stub(:deliver => true))
      PgTools.reset_search_path
      PgTools.set_search_path "schema1"
      ActiveRecord::Base.connection.execute("TRUNCATE users")
      Organisation.stub!(find: mock_model(Organisation, id: 1, client_account_id: 2))
      ClientAccount.stub(find: mock_model(ClientAccount, users: 2))
    end

    it 'should add organisation user' do
      user = User.new
      user.add_company_user(user_params).should be_true

      #PgTools.reset_search_path
      user = user.created_user
      user.should be_persisted
      user.confirmation_token.should_not be_blank
      user.should be_change_default_password

      #user.links.should have(1).element
      user.rol.should == 'operations'
      user.links.first.organisation_id.should == 1

      user.confirmed_at.should be_blank
      user.confirm_token(user.confirmation_token)
      user.confirmed_at.should_not be_blank
    end

    it 'should update the default password' do
      user = User.new

      p = user_params.merge(rolname: "gerency")
      p[:rolname].should == "gerency"
      user.add_company_user(p).should be_true

      user = user.created_user
      UserSession.current_user = user

      user.should be_persisted
      user.should be_change_default_password
      user.rol.should == "gerency"

      user.confirm_token(user.confirmation_token).should be_true

      user.update_default_password(pass_params).should be_true
      user = User.find_by_id(UserSession.user_id)
      user.should_not be_change_default_password
      user = User.find(user.id)
      user.authenticate(pass_params[:password]).should_not be_false
    end

    it 'should not update default password if doesn\'t match' do
      user = User.new

      user.add_company_user(user_params).should be_true
      user = user.created_user
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
      user = user.created_user
      user.should be_persisted
      user.should be_change_default_password

      user.confirm_token(user.confirmation_token).should be_true

      p_params = pass_params.dup.merge(:old_password => user.temp_password)
      user.update_password(p_params).should be_false
    end

    it 'should not allow to add more users' do
      User.stub!(count: 2)

      user = User.new

      user.add_company_user(user_params).should be_false
      user.errors[:base].should_not be_empty
      user.errors[:base].should be_include(I18n.t("errors.messages.user.user_limit") )
    end
  end
  ########################################

  ########################################
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
      Organisation.stub!(find: mock_model(Organisation, id: 1, client_account_id: 2))
      ClientAccount.stub(find: mock_model(ClientAccount, users: 2))
    end

    let!(:user) {
      user = User.new_user("admin@example.com", "demo123")
      user.save_user.should be_true
      user.add_company_user(user_params).should be_true
      user = user.created_user
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

  ########################################
  describe "reset password" do
    let(:pass_params) {
      {:password => "demo123", :password_confirmation => "demo123",
      :old_password=> "demo123"}
    }
    let(:user_params) {
      {:email => 'other@example.com', :first_name => 'Other',
      :last_name => 'User', :rolname => 'operations'}
    }

    before(:each) do
      OrganisationSession.set :id => 1
      RegistrationMailer.stub!(:send_registration => stub(:deliver => true))
      ResetPasswordMailer.stub!(send_reset_password: stub(deliver: true))
      Organisation.stub!(find: mock_model(Organisation, id: 1, client_account_id: 2))
      ClientAccount.stub(find: mock_model(ClientAccount, users: 2))
    end

    let!(:user) {
      user = User.new
      user.add_company_user(user_params)
      user = user.created_user
      user.confirm_token(user.confirmation_token)
      user.update_default_password(pass_params)
      user.confirm_token(user.confirmation_token)
      user
    }

    it 'should reset password' do
      user.rol.should == "operations"
      user.reset_password_token.should be_blank
      user.reset_password_sent_at.should be_blank
      ResetPasswordMailer.stub!(:send_reset_password => stub(:deliver => true))

      user.reset_password.should be_true
      user.reset_password_token.should_not be_blank
      user.reset_password_sent_at.should_not be_blank
    end

    it 'should allow reset and update password' do
      ResetPasswordMailer.stub!(:send_reset_password => stub(:deliver => true))

      PgTools.reset_search_path

      user.reset_password.should be_true
      p_params = {:reset_password_token => user.reset_password_token,
        :password => "newDemo123", :password_confirmation => "newDemo123"
      }
      
      user.can_reset_password?.should be_true
      user.verify_token_and_update_password(p_params).should be_true

      user.reset_password_token.should be_nil
      user.authenticate("demo123").should be_false
      user.authenticate("newDemo123").should be_true
    end

    it 'should not allow reset password when outdated' do
      ResetPasswordMailer.stub!(:send_reset_password => stub(:deliver => true))

      user.reset_password.should be_true
      Time.zone.stub!(:now => Time.zone.now + 2.hours.ago)
      user.can_reset_password?.should be_false
    end
  end
  ########################################
end
