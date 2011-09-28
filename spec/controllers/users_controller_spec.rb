require 'spec_helper'

describe UsersController do
  before do
    controller.stub!(:check_authorization! => true)
  end

  describe "GET /users/update_default_password" do
    it 'should redirect if user has changed default password' do
      user_mock = mock_model(User, :change_default_password? => false)
      controller.stub!(:current_user => user_mock)

      get :default_password

      response.should redirect_to("/422")
    end

    it 'should present the correct tempalate' do
      controller.stub!(:current_user => mock_model(User, :change_default_password? => true))

      get :default_password

      response.should render_template("default_password")
    end
  end

  describe "PUT /users/:id/update_password" do
    it 'should update the password for a user' do
      user_mock = mock_model(User, :change_default_password? => true, 
                             :update_password => true, :id => 1)
      controller.stub!(:current_user => user_mock)

      put :update_default_password, :id => 1, :user => {:password => 'demo123', :password_confirmation => 'demo123'}

      response.should redirect_to user_mock
    end

    it 'should render default_password if wrong' do
      user_mock = mock_model(User, :change_default_password? => true, 
                             :update_password => false, :id => 1)
      controller.stub!(:current_user => user_mock)

      put :update_default_password, :id => 1, :user => {:password => 'demo123', :password_confirmation => 'demo123'}

      response.should render_template("default_password")
    end

    it 'should redirect if change_default_password? is false' do
      
      user_mock = mock_model(User, :change_default_password? => false)
      controller.stub!(:current_user => user_mock)

      put :update_default_password, :id => 1

      response.should redirect_to("/422")
    end
  end

  describe "update_password" do
    it 'should redirect to default_password' do
      user_mock = mock_model(User, :change_default_password? => true)
      controller.stub!(:current_user => user_mock)

      get :password

      response.should redirect_to(default_password_users_path)
    end

    it 'should redirect to default_password' do
      user_mock = mock_model(User, :change_default_password? => true)
      controller.stub!(:current_user => user_mock)

      put :update_password, :id => 1

      response.should redirect_to(default_password_users_path)
    end

    it 'should render template' do
      user_mock = mock_model(User, :change_default_password? => false)
      controller.stub!(:current_user => user_mock)

      get :password

      response.should render_template("password")
    end
  end
end
