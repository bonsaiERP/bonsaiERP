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
      User.stub!(:find_by_id => stub(:confirm_token => true, :id => 1,
            :organisations => stub(:any? => false)
          ))
      controller.stub!(:current_user => User.new {|u| u.id = 1})

      get 'show', :id => 1, :token => "demo123"

      response.should redirect_to "/organisations/new"
      session[:user_id].should == 1
    end

    it 'should redirect to /dashboard if it has organisation' do
      user_stubs = stub(:confirm_token => true, :id => 1, rol: "admin", 
                        active: true, active?: true,
                        links: [mock_model(Link, rol: "admin")],
                        :organisations => [mock_model(Organisation, id: 1)]
          )
      User.stub!(find: user_stubs, find_by_id: user_stubs)
      PgTools.stub!(schema_exists?: true, set_search_path: true)
      controller.stub!( :set_organisation_session => true )

      get 'show', :id => 1, :token => "demo123"

      response.should redirect_to "/dashboard"
      session[:user_id].should == 1
    end

    it 'should redirect to registers/new in case of wrong token' do
      get 'show', :id => 1, :token => '123'

      response.should redirect_to "/registrations/new"
      flash[:warning].should_not be_blank
    end

  end

  describe "GET registrations if logged user" do
    it 'should redirect to dashboard if logged user' do
      user_stubs = stub(:confirm_token => true, :id => 1, rol: "admin", 
                        active: true, active?: true,
                        links: [mock_model(Link, rol: "admin")],
                        :organisations => [mock_model(Organisation, id: 1)]
          )
      session[:user_id] = 1
      User.stub!(find: user_stubs, find_by_id: user_stubs)
      controller.stub!(:set_organisation_session => true)
      PgTools.stub!(schema_exists?: true, set_search_path: true)

      get 'new'
      response.should redirect_to("/dashboard")
    end
  end
end
