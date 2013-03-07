require 'spec_helper'

describe RegistrationsController do
  let(:tenant) { 'tenant' }

  before(:each) do
    ALLOW_REGISTRATIONS = true
  end

  describe "GET /registrations/new" do
    it 'should redirect to register' do
      get 'new'

      response.should be_success
    end

    it "not allowed registration" do
      ALLOW_REGISTRATIONS = false

      get 'new'

      response.should be_redirect
    end
  end

  describe "GET /show" do

    let(:current_organisation) { build(:organisation, id: 1) }

    before(:each) do
      controller.stub(current_organisation: current_organisation)
    end

    it 'confirm token' do
      current_organisation.stub_chain(:users, find_by_confirmation_token: user = build(:user, id: 1))
      user.stub(save: true)

      request.stub(subdomain: tenant)

      get 'show', :id => 1, :token => "demo123"

      response.should redirect_to new_organisation_path
      session[:user_id].should == 1
    end

    it 'redirect to registration if wrong token' do
      request.stub(subdomain: tenant)
      get 'show', id: 1, token: 'token123'

      response.should redirect_to "http://#{DOMAIN}?error_conf_token"
    end

  end

  describe "POST /create" do
    it "creates" do
      Registration.any_instance.stub(register: true)
      RegistrationMailer.should_receive(:send_registration).and_return(stub(deliver: true))

      post :create, registration: {tenant: tenant,email: 'test@mail.com'}

      response.should redirect_to(registrations_path)
      flash[:notice].should eq("Le hemos enviado un email a test@mail.com con instrucciones para completar su registro.")
    end

    it "does not allow registration" do
      ALLOW_REGISTRATIONS = false

      post :create, registration: {tenant: tenant, email: 'test@mail.com'}

      response.should be_redirect
      response.should redirect_to(root_path)
    end
  end

  describe "redirections" do
    before(:each) do
      request.stub(subdomain: 'asubdomain')
    end

    #it "redirects to login" do
      #PgTools.stub(schema_exists?: true)

      #{get: :show, get: :new_user}.each do |m, action|
        #send(m, action, {id: 1})

        #response.should redirect_to new_session_url(host: UrlTools.domain)
        #flash[:alert].should eq('Por favor ingrese.')
      #end
    #end

    #it "redirects to registration without domain" do
      #PgTools.stub(schema_exists?: false)
      #request.stub(subdomain: '')

      #{get: :show, get: :new_user}.each do |m, action|
        #send(m, action, {id: 1})

        #response.should redirect_to new_registration_url(host: UrlTools.domain)
      #end
    #end
  end

  describe "get /new_user" do
    let(:current_organisation) { build(:organisation, id: 1) }

    before(:each) do
      controller.stub(current_organisation: current_organisation)
    end

    it "confirm new user" do
      session[:user_id].should be_blank
      current_organisation.stub_chain(:users, find_by_confirmation_token: user = build(:user, id: 1))
      user.stub(save: true)
      PgTools.stub(schema_exists?: true)
      
      get :new_user, id: 'token123'

      response.should redirect_to dashboard_path
      flash[:notice].should eq('Ha confirmado su registro correctamente.')
    end
  end

end
