# encoding: utf-8
require 'spec_helper'

describe UserPasswordsController do
  let(:user) { build :user, id: 10 }

  before(:each) do
    stub_auth
    user.stub(persisted?: true)
    controller.stub(current_user: user)
  end

  it "check stubed methods" do
    [:update_password].each do |m|
      UserPassword.should be_method_defined(m)
      UpdateDefaultPassword.should be_method_defined(m)
    end
  end

  describe "GET /user_passwords/new" do
    it "change_default_password" do
      get :new

      response.should render_template('new')
      assigns(:user_password).should be_is_a(UserPassword)
    end

    it "redirects" do
      user.change_default_password = true
      get :new

      response.should redirect_to(new_default_user_passwords_path)
    end
  end

  describe "POST /user_passwords" do
    # A user that has it's own password
    it "updates" do
      UserPassword.any_instance.stub(update_password: true)
      post :create, user_password: {password: '1234', password_confirmation: '1234', old_password: 'demo1234'}

      response.should redirect_to(user_path(10))
      flash[:notice].should eq "Su contraseña ha sido actualizada."
    end

    # A user that has it's own password
    it "update error" do
      UserPassword.any_instance.stub(update_password: false)
      post :create, user_password: {password: '1234', password_confirmation: '1234', old_password: 'demo1234'}

      response.should render_template('new')
    end
  end

  describe "GET /user_password/new_default" do
    it "new_default" do
      user.change_default_password = true
      get :new_default

      response.should render_template('new_default')
    end

    it "redirects if change default password" do
      user.change_default_password = false

      get :new_default

      response.should redirect_to(new_user_password_path)
    end
  end

  describe 'POST /user_passwords/create_default' do
    it "updates" do
      user.change_default_password = true
      UpdateDefaultPassword.any_instance.stub(update_password: true)

      post :create_default, update_default_password: {password: '1234', password_confirmation: '1234'}

      response.should redirect_to(user_path(10))
      flash[:notice].should eq "Su contraseña ha sido actualizada."
    end

    it "error" do
      user.change_default_password = true
      UserPassword.any_instance.stub(update_default_password: false)
      post :create_default, update_default_password: {password: '1234', password_confirmation: '1234'}

      response.should render_template('new_default')
    end

    it "redirects" do
      user.change_default_password = false

      post :create_default

      response.should redirect_to(new_user_password_path)
    end
  end
end
