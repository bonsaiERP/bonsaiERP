# encoding: utf-8
require 'spec_helper'
describe BanksController do
  before(:each) do
    stub_auth
  end


  describe "GET /new" do
    it "creates a new instance of Bank calling money_store" do
      get :new

      assigns(:bank).should be_is_a(Bank)
      assigns(:bank).should respond_to(:address)
      response.should render_template('new')
    end
  end

  describe "GET /show" do
    it "returns a bank" do
      Bank.stub(find: build(:bank, id: 23))

      get :show, id: 23

      response.should render_template('show')
    end
  end

  describe "POST /create" do
    it "creates an instance of Bank" do
      Bank.any_instance.stub(save: true, id: 23, persisted?: true)
      post :create, bank: {name: 'Name'}

      response.should redirect_to bank_path(23)
      flash[:notice].should eq('La cuenta de banco fue creada.')
    end
  end
end
