# encoding: utf-8
require 'spec_helper'

describe AdminUsersController do
  before(:each) do
    stub_auth
    controller.stub(currency: 'BOB')
  end

  describe "GET 'new'" do
    it "returns http success" do
      get :new

      response.should be_success
      assigns(:admin_user).should be_is_a(AdminUser)
    end
  end

  it "checks stub methods" do
    AdminUser.should be_method_defined(:create)
    AdminUser.should be_method_defined(:update)
    AdminUser.should be_respond_to(:find)
  end

  describe "POST 'create'" do
    it "Create user" do
      AdminUser.any_instance.stub( create: true )

      post :create, admin_user: { email: '' }

      response.should redirect_to configurations_path
      flash[:notice].should eq('El usuario ha sido adicionado.')
    end

    it "renders new" do
      AdminUser.any_instance.stub(add_user: false)

      post :create, admin_user: {email: ''}

      response.should render_template('new')
      assigns(:admin_user).should be_is_a(AdminUser)
    end
  end

  let(:organisation) { build :organisation, id: 2, tenant: 'jeje' }

  describe "GET 'edit'" do
    it "edit" do
      controller.should_receive(:check_master_account)
      controller.stub(current_organisation: organisation)

      AdminUser.should_receive(:find).with(organisation, '2')

      get :edit, id: 2
    end
  end

  describe "PATCH 'update'" do
    it "udpate" do
      controller.should_receive(:check_master_account)
      controller.stub(current_organisation: organisation)

      AdminUser.stub(find: AdminUser)
      AdminUser.should_receive(:update).with({ 'first_name' => 'Juan'}).and_return(true)

      patch :update, id: 2, admin_user: {email: 'juan@mail.com', first_name: 'Juan'}

      response.should redirect_to(configurations_path)
      flash[:notice].should be_present
    end

    it "update Error" do
      controller.should_receive(:check_master_account)
      controller.stub(current_organisation: organisation)

      AdminUser.stub(find: AdminUser)
      AdminUser.should_receive(:update).with({ 'first_name' => 'Juan'}).and_return(false)

      patch :update, id: 2, admin_user: {email: 'juan@mail.com', first_name: 'Juan'}

      response.should render_template(:edit)
    end
  end

end
