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
    before do
      
    end

    let(:user_mock){
      user_mock = mock_model(User, :id => 1, :confirmated? => true, :organisations => [])
      user_mock.stub!(:authenticate).with("demo123")
      user_mock
    }

    it 'should login' do
      User.stub!(:find_by_email).with("demo@example.com").and_return(user_mock)
      controller.stub!(:current_user => user_mock)

      post "create", :user => {:email => "demo@example.com", :password => "demo123"}

      response.should redirect_to "/organisations/new"
    end

    it 'should redirect correctly' do
      user_mock.stub!(:organisations => [mock_model(Organisation, :id => 1)],
                     :link => stub(:rol => 'admin'))
      
      User.stub!(:find_by_email).with("demo@example.com").and_return(user_mock)

      controller.stub!(:current_user => user_mock, :set_organisation_session => true)

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
  end
end
