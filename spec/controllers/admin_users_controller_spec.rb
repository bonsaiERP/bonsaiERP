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

  describe "POST 'create'" do
    it "returns http success" do
      #get 'create'
      #response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end

end
