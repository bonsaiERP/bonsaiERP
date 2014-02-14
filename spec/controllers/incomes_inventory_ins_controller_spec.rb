require 'spec_helper'

describe IncomesInventoryInsController do
  before(:each) do
    stub_auth
  end

  it "check_methods" do
    Incomes::InventoryIn.should be_method_defined(:build_details)
  end

  describe '/new' do
    it ":new" do
      Income.should_receive(:find).with('1').and_return(build(:income, id: 1))
      Income.should_receive(:active).and_return(Income)
      Store.should_receive(:find).with('2').and_return(build(:store, id: 2))
      Store.should_receive(:active).and_return(Store)

      Incomes::InventoryIn.any_instance.should_receive(:build_details)

      get :new, income_id: 1, store_id: 2

      response.should be_success
      response.should render_template(:new)
    end
  end

  describe '/create' do
    it ":create" do
      Income.stub_chain(:active, find: build(:income, id: 1))
      Store.stub_chain(:active, find: build(:income, id: 1))

      Incomes::InventoryIn.any_instance.should_receive(:create).and_return(true)

      post :create, incomes_inventory_in: { description: 'test', inventory_details_attributes: [{item_id: 1, quantity: 2}] }

      response.should redirect_to(income_path(1))
      flash[:notice].should be_present
    end

    it ":create ERROR" do
      Income.stub_chain(:active, find: build(:income, id: 1))
      Store.stub_chain(:active, find: build(:income, id: 1))

      Incomes::InventoryIn.any_instance.should_receive(:create).and_return(false)

      post :create, incomes_inventory_in: { description: 'test', inventory_details_attributes: [{item_id: 1, quantity: 2}] }

      response.should render_template(:new)
    end
  end
end
