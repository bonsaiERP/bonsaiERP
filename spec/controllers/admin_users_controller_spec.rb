require 'spec_helper'

describe AdminUsersController do
  before(:each) do
    stub_auth
    controller.stub(currency: 'BOB')
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
      assigns(:user).should be_is_a(User)
    end
  end

  it "checks stub methods" do
    AdminUser.should be_method_defined :add_user
  end

  describe "POST 'create'" do
    it "Create user" do
      AdminUser.any_instance.stub(add_user: true)

      post :create, user: {email: ''}

      response.should redirect_to configurations_path
      flash[:notice].should eq('El usuario ha sido adicionado.')
    end

    it "renders new" do
      AdminUser.any_instance.stub(add_user: false)

      post :create, user: {email: ''}

      response.should render_template('new')
      assigns(:user).should be_is_a(User)
    end
  end

  describe "GET 'edit'" do
    it "edit"
  end

  describe "PUT 'update'" do
    it "udpate"
  end

end
