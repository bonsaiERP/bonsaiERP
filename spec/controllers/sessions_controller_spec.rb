require 'spec_helper'

describe SessionsController do
  describe "GET /sessions" do
    it 'should render the correct template' do
      get 'new'

      assigns(:user).class.to_s.should == "User"
    end
  end

  describe "POST /sessions" do
    it 'should login' do
      obj = Object.new
      obj.stub!(:authenticate => true, :id => 1, :organisations => [])
      User.stub!(:find_by_email => obj)

      post "create", :user => {:email => "demo@example.com"}

      response.should redirect_to "/organisations/new"
    end

    it 'should redirect correctly' do
      obj = Object.new
      obj.stub!(:authenticate => true, :id => 1, :organisations => [Organisation.new], :link => stub(:rol => 'admin'))
      User.stub!(:find_by_email => obj)
      controller.stub!(:set_organisation_session => true)

      post "create", :user => {:email => "demo@example.com"}

      response.should redirect_to "/dashboard"
    end

    it 'should render the same ' do
      obj = Object.new
      obj.stub!(:authenticate => false)
      User.stub!(:find_by_email => obj)
      
      post "create", :user => {:email => "demo@example.com"}

      response.should render_template("new")
      assigns(:user).errors.messages[:password].should_not be_blank
    end
  end
end
