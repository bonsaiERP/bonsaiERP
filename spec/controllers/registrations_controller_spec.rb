require 'spec_helper'

describe RegistrationsController do
  let(:tenant) { 'tenant' }

  before(:each) do
    #ALLOW_REGISTRATIONS = true
  end

  describe "GET /registrations/new" do
    it 'should redirect to register' do
      get 'new'

      expect(response.ok?).to eq(true)
    end

    #it "not allowed registration" do
    #  ALLOW_REGISTRATIONS = false

    #  get 'new'

    #  expect(response.redirect?).to eq(true)
    #end
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

      expect(response).to redirect_to(controller.new_organisation_path)
      session[:user_id].should == 1
    end

    it 'redirect to registration if wrong token' do
      request.stub(subdomain: tenant)
      get 'show', id: 1, token: 'token123'

      expect(response).to redirect_to("http://#{DOMAIN}?error_conf_token")
    end

  end

  describe "POST /create" do
    it "creates" do
      Registration.any_instance.stub(register: true)
      RegistrationMailer.should_receive(:send_registration).and_return(double(deliver: true))

      post :create, registration: {tenant: tenant,email: 'test@mail.com'}

      expect(response).to redirect_to(controller.registrations_path)
      expect(controller.flash[:notice]).to eq("Le hemos enviado un email a test@mail.com con instrucciones para completar su registro.")
    end

    #it "does not allow registration" do
    #  ALLOW_REGISTRATIONS = false

    #  post :create, registration: {tenant: tenant, email: 'test@mail.com'}

    #  expect(response.redirect?).to eq(true)
    #  expect(response).to redirect_to(root_path)
    #end
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


end
