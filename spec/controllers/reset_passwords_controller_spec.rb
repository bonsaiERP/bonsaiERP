require 'spec_helper'

describe ResetPasswordsController do

  it "test stubed method" do
    [:reset_password].each  do |m|
      ResetPassword.should be_method_defined(m)
    end
  end

  describe 'GET /reset_passwords/new' do
    it "renders the new" do
      get :new

      response.should be_success
      response.should render_template('new')
      assigns(:reset_password).should be_is_a(ResetPassword)
    end
  end

  describe 'POST /reset_passwords' do
    it "sends email" do
      ResetPassword.any_instance.should_receive(:reset_password).and_return(true)

      post :create, reset_password: {email: 'test@mail.com'}

      response.should render_template('create')
    end

    it "presets error" do
      ResetPassword.any_instance.should_receive(:reset_password).and_return(false)

      post :create, reset_password: {email: 'test@mail.com'}

      response.should render_template('new')
      flash[:error].should_not be_blank
    end
  end

  let(:user) { build :user, id: 1 }

  describe 'GET /reset_passwords/:id/edit' do

    it "#edit" do
      User.stub_chain(:active, where: [user])

      get :edit, id: 'token123'

      response.should render_template('edit')
    end

    it "redirects" do
      User.stub_chain(:active, where: [])

      get :edit, id: 'token123'

      response.should redirect_to new_session_url(subdomain: false)
    end
  end

  describe 'PUT /reset_passwords/:id' do
    before(:each) do
      UserPassword.any_instance.stub(user: user)
      User.stub_chain(:active, where: [user])
    end

    it "redirects to dashboard" do
      UserPassword.any_instance.should_receive(:update_reset_password).with(user).and_return(true)
      user.stub(auth_token: 'auth_token_123', active_links: [build(:link, tenant: 'bonsai')])

      put :update, id: 'token123', user_password: {password: ''}

      response.should redirect_to(dashboard_url(host: UrlTools.domain, auth_token: 'auth_token_123', subdomain: 'bonsai'))
    end

    it 'renders edit' do
      UserPassword.any_instance.should_receive(:update_reset_password).with(user).and_return(false)

      put :update, id: 'token123', user_password: {password: ''}

      response.should render_template('edit')
    end

  end

end
