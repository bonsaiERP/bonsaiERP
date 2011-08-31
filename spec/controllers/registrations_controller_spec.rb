require 'spec_helper'

describe RegistrationsController do
  describe "GET /registrations/new" do
    it 'should redirect to register' do
      get 'new'

      response.should be_success
    end

  end

  describe "GET /show" do
    it 'should confirm token' do
      User.stubs(:find_by_id => stub(:confirm_token => true, :id => 1))

      get 'show', :id => 1, :token => "demo123"

      response.should redirect_to "/organisations/new"
      session[:user_id].should == 1
    end

    it 'should redirect to registers/new in case of wrong token' do
      get 'show', :id => 1, :token => '123'

      response.should redirect_to "/registrations/new"
      flash[:warning].should_not be_blank
    end

    it 'should redirect to sessions/new if user registered' do
      User.any_instance.stubs(:confirm_token => false)
      User.stubs(:find_by_id => User.new)
      
      get 'show', :id => 1, :token => '123'
      response.should redirect_to "/sessions/new"
    end
  end

  describe "GET registrations if logged user" do
    it 'should redirect to dashboard if logged user' do
      session[:user_id] = 1
      u = User.new(:email => 'demo@example.com') {|u| u.id = 1}
      u.stubs(:organisations => [Organisation.new], :link => stub(:rol => 'admin'))
      User.stubs(:find => u )
      controller.stubs(:set_organisation_session => true)

      get 'new'
      response.should redirect_to("/dashboard")
    end
  end
end
