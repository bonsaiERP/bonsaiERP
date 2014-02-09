require 'spec_helper'
describe CashesController do
  before(:each) do
    stub_auth
  end

  describe "GET /new" do
    it "creates a new instance of Bank calling money_store" do
      get :new

      assigns(:cash).should be_is_a(Cash)
      assigns(:cash).should respond_to(:address)
      response.should render_template('new')
    end
  end

  describe "GET /show" do
    it "returns a cash" do
      Cash.stub(find: build(:cash, id: 23))

      get :show, id: 23

      response.should render_template('show')
    end
  end

  describe "POST /create" do
    it "creates an instance of Bank" do
      Cash.any_instance.stub(save: true, id: 23, persisted?: true)
      post :create, cash: {name: 'Name'}

      response.should redirect_to cash_path(23)
      flash[:notice].should eq('La cuenta efectivo fue creada.')
    end

    it "only sets with create_bank_params" do
      Cash.any_instance.stub(save: true, id: 23, persisted?: true)
      post :create, cash: {name: 'Name', amount: '1200'}

      response.should redirect_to cash_path(23)
      assigns(:cash).amount.should eq(1200)
    end
  end

  describe "PUT /update" do
    it "only assings update_params" do
      Cash.any_instance.stub(save: true, persisted?: true)
      Cash.stub(find: build(:cash, id: 23))

      put :update, id: 23, cash: { name: 'Name', amount: '1200', currency: 'USD' }

      response.should redirect_to cash_path(23)
      flash[:notice].should_not be_blank
    end
  end
end

