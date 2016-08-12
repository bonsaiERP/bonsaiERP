require "spec_helper"

describe SessionsController do

  it "checks all stubbed methods" do
    [:authenticate?, :tenant].each do |m|
      expect(Session.method_defined?(m)).to eq(true)
    end
    User.new # Needed to check methods
    [:set_auth_token, :auth_token].each do |m|
      expect( User.method_defined?(m) ).to eq(true)
    end
  end

  describe "GET /sessions" do
    it "should render the correct template" do
      get 'new'

      expect(assigns(:session).is_a?(Session)).to eq(true)
    end

    let(:user) { build :user }

    it "redirects when logged" do
      session[:user_id] = 1
      User.stub_chain(:active, find: user)
      user.stub(organisations: [(build :organisation, tenant: 'bonsai')])
      session[:tenant] = "bonsai"

      get :new

      expect( response.redirect_url ).to match("/home")

      stub_const("USE_SUBDOMAIN", true)

      get :new
      expect( response.redirect_url ).to eq(home_url(host: DOMAIN, subdomain: session[:tenant]))
    end
  end


  describe "POST /sessions" do

    let(:user){
      u = build :user, id: 1
      u.stub(confirmated?: true, organisations: [], valid_password?: true)
      u
    }

    it "#create login" do
      Session.any_instance.stub(authenticate?: true, user: user, tenant: "bonsai")
      session[:tenant] = "bonsai"

      post "create", session: {email: "demo@example.com", password: "demo123"}

      expect(response.redirect_url).to match(home_path)
    end

    #it "Resends registration email" do
    #  RegistrationMailer.should_receive(:send_registration).and_return(stub(deliver: true))
    #  Session.any_instance.stub(authenticate?: false, status: 'resend_registration')

    #  post :create, session: {email: "demo@example.com", password: "demo123"}

    #  response.should redirect_to registrations_url(subdomain: false)
    #  flash[:notice].should eq("Le hemos reenviado el email de confirmación a demo@example.com")
    #end


    it "wrong email or password" do
      Session.any_instance.stub(authenticate: false)

      post "create", session: {email: "demo@example.com", password: "demo123"}

      expect(response).to render_template(:new)
      expect(flash.now[:error]).to eq(I18n.t("views.sessions.flash_login_error"))
    end
  end

  describe "GET /destroy" do
    it "#destroy" do
      get :destroy

      expect(response.redirect_url).to match(login_path)
    end
  end
end
