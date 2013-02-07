require 'spec_helper'

describe RegistrationsController do
  let(:tenant) { 'tenant' }

  describe "GET /registrations/new" do
    it 'should redirect to register' do
      get 'new'

      response.should be_success
    end

  end

  describe "GET /show" do
    it 'confirm token' do
      org = build(:organisation, id: 1)
      org.stub_chain(:users, find_by_confirmation_token: user = build(:user, id: 1))
      user.stub(save: true)
      controller.stub!(current_organisation: org)

      get 'show', :id => 1, :token => "demo123"

      response.should redirect_to new_organisation_path
      session[:user_id].should == 1
    end

    it 'redirect to sign_in if tenant created' do
      request.stub!(subdomain: tenant)
      PgTools.stub!(schema_exists?: true)

      get 'show', :id => 1, :token => "demo123"

      response.should redirect_to new_session_url(host: UrlTools.domain)
      flash[:alert].should_not be_blank
    end

    it 'redirect to registration if wrong token' do
      get 'show', :id => 1, :token => '123'

      response.should redirect_to new_registration_url(host: UrlTools.domain)
      flash[:alert].should_not be_blank
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
  end

  describe "redirections" do
    before(:each) do
      request.stub(subdomain: 'asubdomain')
    end

    it "redirects to login" do
      PgTools.stub(schema_exists?: true)

      {get: :new, post: :create}.each do |m, action|
        send(m, action)

        response.should redirect_to new_session_url(host: UrlTools.domain)
        flash[:alert].should eq('Por favor ingrese.')
      end
    end


    it "redirects to registration without domain" do
      get :new

      response.should redirect_to new_registration_url(host: UrlTools.domain)
      response.redirect_url.should_not match(/asubdomain/)
    end
  end

end
