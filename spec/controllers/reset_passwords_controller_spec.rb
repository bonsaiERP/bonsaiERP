require 'spec_helper'

describe ResetPasswordsController do

  it "test stubed method" do
    [:reset_password].each  do |m|
      ResetPasswordEmail.should be_method_defined(m)
    end
    ResetPassword.should be_method_defined(:update_password)
  end

  describe 'GET /reset_passwords/new' do
    it "renders the new" do
      get :new

      response.should be_success
      response.should render_template('new')
      assigns(:reset_password).should be_is_a(ResetPasswordEmail)
    end
  end

  describe 'POST /reset_passwords' do
    it "sends email" do
      ResetPasswordEmail.any_instance.should_receive(:reset_password).and_return(true)

      post :create, reset_password_email: {email: 'test@mail.com'}

      response.should redirect_to(reset_passwords_path)
    end

    it "presets error" do
      ResetPasswordEmail.any_instance.should_receive(:reset_password).and_return(false)

      post :create, reset_password_email: {email: 'test@mail.com'}

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
      ResetPassword.any_instance.should_receive(:update_password).and_return(true)

      put :update, id: 'token123', reset_password: { password: 'demo1234', password_confirmation: 'demo1234', user: user}

      response.should redirect_to(login_path)
      assigns[:reset_password].should be_is_a(ResetPassword)
      rp = assigns[:reset_password]
      rp.user.should eq(user)
      rp.password.should eq('demo1234')
      rp.password_confirmation.should eq('demo1234')
    end

    it 'renders edit' do
      ResetPassword.any_instance.should_receive(:update_password).and_return(false)

      put :update, id: 'token123', reset_password: {password: 'demo', password_confirmation: 'demo'}

      response.should render_template('edit')
    end

  end

end
