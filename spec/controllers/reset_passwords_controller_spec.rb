require 'spec_helper'

describe ResetPasswordsController do
  describe "GET /reset_passwords/new" do
    it 'should render template' do
      get :new

      response.should render_template("new")
    end
  end

  describe "POST /reset_passwords" do
    it 'should resent email' do
      User.stub!(:find_by_email => mock_model(User, :email => 'demo@example.com', :id => 1, :confirmated? => true, :reset_password => true))

      post :create, :user => {:email => 'demo@example.com'}
      response.should render_template("reset")
    end

    it 'should redirect to session if not confirmed?' do
      User.stub!(:find_by_email => mock_model(User, :email => 'demo@example.com', :id => 1, :confirmated? => false))

      post :create, :user => {:email => 'demo@example.com'}
      response.should redirect_to(session_path(1))
    end

    it 'should preset error if the email is not found' do
      User.stub!(:find_by_email => nil)

      post :create, :user => {:email => 'demo@example.com'}
      response.should render_template("new")
      assigns(:user).errors[:email].should_not be_blank
    end
  end

  describe "GET /edit" do
    it 'should present edit' do
      User.stub!(:find_by_id_and_reset_password_token => mock_model(User, :can_reset_password? => true))
      get :edit, :id => 1, :reset_password_token => "uw7yrsfhu"
      response.should render_template("edit")
    end

    it 'should redirect if oudated or not found' do
      User.stub!(:find_by_id_and_reset_password_token => mock_model(User, :can_reset_password? => false))
      get :edit, :id => 1, :reset_password_token => "uw7yrsfhu"
      response.should redirect_to("new")
      flash[:warning].should_not be_blank
    end
  end

  describe "PUT /update" do
    it 'should update if correct data' do
      user_mock = mock_model(User,:organisations => [mock_model(Organisation, :id => 1)], :link => stub(:rol => "admin"), :id => 1,
                    :verify_token_and_update_password => true, :can_reset_password? => true
                            )
      controller.stub!(:current_user => user_mock, :set_organisation_session => true)
      User.stub!(:find_by_id_and_reset_password_token => user_mock)
      
      put :update, :id => 1, :user => {:reset_password_token => "8yse5uhifs", :password => 'demo123', :password_confirmation => 'demo123'}

      response.should be_redirect
    end
  end
end
