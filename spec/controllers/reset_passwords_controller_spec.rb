require 'spec_helper'

describe ResetPasswordsController do
  before(:each) do

  end

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

  describe 'GET /reset_passwords/:id/edit' do
  end

end
