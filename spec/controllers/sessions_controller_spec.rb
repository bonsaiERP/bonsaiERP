require 'spec_helper'

describe SessionsController do
  describe "GET /sessions" do
    it 'should render the correct template' do
      User.stub!(:new => mock_model(User))
      get 'new'

      assigns(:user).class.to_s.should == "User"
    end
  end


  describe "POST /sessions" do

    let(:user_mock){
      user_mock = mock_model(User, :id => 1, :confirmated? => true, :organisations => [])
      user_mock.stub!(:authenticate).with("demo123")
      user_mock
    }

    it 'should login' do
      User.stub!(:find_by_email).with("demo@example.com").and_return(user_mock)
      PgTools.stub!(set_search_path: false)

      controller.stub!(:current_user => user_mock)

      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should redirect_to "/organisations/new"
    end

    it 'should redirecto to /organisations/:id/create_data' do
      user_mock.stub!(:organisations => [mock_model(Organisation, :id => 1)],
                     :link => stub(:rol => 'admin'))
      
      User.stub!(:find_by_email).with("demo@example.com").and_return(user_mock)

      PgTools.stub!(set_search_path: true)
      PgTools.stub!(created_data?: false)

      controller.stub!(:current_user => user_mock, :set_organisation_session => true)
      PgTools.stub!(set_search_path: Object.new)

      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should redirect_to create_data_organisation_path(1)
      
    end

    it 'should redirect to /dashboard if created tenant' do
      user_mock.stub!(:organisations => [mock_model(Organisation, :id => 1)],
                     :link => stub(:rol => 'admin'))
      
      User.stub!(:find_by_email).with("demo@example.com").and_return(user_mock)

      PgTools.stub!(set_search_path: true)
      PgTools.stub!(created_data?: true)

      controller.stub!(:current_user => user_mock, :set_organisation_session => true)
      PgTools.stub!(set_search_path: Object.new)

      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should redirect_to "/dashboard"
    end

    it 'should render the new template when incorrect password' do
      User.stub!(:find_by_email).with("demo@example.com").and_return(nil)
      
      post "create", :user => {:email => "demo@example.com", :password => "demo1234"}

      response.should render_template("new")
    end

    it 'should render the same template with errors' do
      user_mock.stub!(:authenticate => false)
      User.stub!(:find_by_email => user_mock)
      
      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should render_template("new")
      assigns(:user).errors.messages[:password].should_not be_blank
    end

    it 'should return errors when email invalid' do
      User.stub!(:find_by_email => nil)
      
      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should render_template("new")
      assigns(:user).errors.messages[:email].should_not be_blank
    end

    it 'should redirect to show page if not confirmed token' do
      user_mock.stub!(:confirmated? => false)
      User.stub!(:find_by_email => user_mock)

      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should redirect_to("/sessions/1")
    end

    # Check if tenant hsa been created
    it 'should redirect to /organisations/:id/create_tenant when not created tenant' do
      user_mock.stub!(:organisations => [mock_model(Organisation, :id => 1)],
                     :link => stub(:rol => 'admin'))
      
      User.stub!(:find_by_email).with("demo@example.com").and_return(user_mock)

      controller.stub!(:current_user => user_mock, :set_organisation_session => true)
      PgTools.stub!(set_search_path: false)

      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should redirect_to create_tenant_organisation_path(1)
    end

    it 'should redirect to create_data if no data created' do
      
    end
  end

  describe "GET /show" do
    before do
      controller.stub!(:current_user => nil)
    end

    let(:user_mock){
      user_mock = mock_model(User, :id => 1, :confirmated? => true, :organisations => [])
      user_mock.stub!(:authenticate).with("demo123")
      user_mock
    }

    it 'should redirect if confirmed?' do
      User.stub!(:find_by_id).with("1").and_return(user_mock)

      get "show", :id => 1

      response.should redirect_to "/sessions/new"
    end

    it 'should resend confirmation if not confirmed' do
      user_mock.stub!(:confirmated? => false, :resend_confirmation => true)
      User.stub!(:find_by_id).with("1").and_return(user_mock)

      get "show", :id => 1

      response.should_not be_redirect
      assigns(:user).class.should == User
      response.should render_template("show")
    end

    it 'should rendirect to registrations if user not found' do
      User.stub!(:find_by_id).with("1").and_return(nil)

      get "show", :id => 1

      response.should redirect_to(new_registration_path)
    end
  end
end
