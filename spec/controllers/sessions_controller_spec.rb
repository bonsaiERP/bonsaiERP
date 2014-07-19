# encoding: utf-8
require 'spec_helper'

describe SessionsController do

  it "checks all stubbed methods" do
    [:authenticate?, :tenant].each do |m|
      Session.method_defined?(m).should be_true
    end
    User.new # Needed to check methods
    [:set_auth_token, :auth_token].each do |m|
      User.method_defined?(m).should be_true
    end
  end

  describe "GET /sessions" do
    it 'should render the correct template' do
      get 'new'

      assigns(:session).should be_is_a(Session)
    end

    let(:user) { build :user }

    it "redirects when logged" do
      session[:user_id] = 1
      User.stub_chain(:active, find: user)
      user.stub(organisations: [(build :organisation, tenant: 'bonsai')])

      get :new

      response.should redirect_to(dashboard_url(host: DOMAIN, subdomain: 'bonsai'))
    end
  end


  describe "POST /sessions" do

    let(:user){
      u = build :user, id: 1
      u.stub(confirmated?: true, organisations: [], valid_password?: true)
      u
    }

    it '#create login' do
      Session.any_instance.stub(authenticate?: true, user: user, tenant: 'bonsai')

      post "create", session: {email: "demo@example.com", password: "demo123"}

      response.should redirect_to dashboard_url(host: DOMAIN, subdomain: 'bonsai')
    end

    it 'Resends registration email' do
      RegistrationMailer.should_receive(:send_registration).and_return(stub(deliver: true))
      Session.any_instance.stub(authenticate?: false, status: 'resend_registration')

      post :create, session: {email: "demo@example.com", password: "demo123"}

      response.should redirect_to registrations_url(subdomain: false)
      flash[:notice].should eq("Le hemos reenviado el email de confirmación a demo@example.com")
    end


    it "wrong email or password" do
      Session.any_instance.stub(authenticate: false)

      post "create", session: {email: "demo@example.com", password: "demo123"}

      response.should render_template('new')
      flash.now[:error].should eq('El email o la contraseña que ingreso no existen.')
    end
  end

  describe "GET /destroy" do
    it "#destroy" do
      get :destroy

      response.should redirect_to(login_url(host: DOMAIN, subdomain: false))
    end
  end
end
