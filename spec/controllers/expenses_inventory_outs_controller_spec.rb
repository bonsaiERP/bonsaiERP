require 'spec_helper'

describe ExpensesInventoryOutsController do
  before(:each) do
    stub_auth
  end

  it "check_methods" do
    Expenses::InventoryOut.should be_method_defined(:build_details)
  end

  describe '/new' do
    it ":new" do
      Expense.should_receive(:find).with('1').and_return(build(:expense, id: 1))
      Expense.should_receive(:active).and_return(Expense)
      Store.should_receive(:find).with('2').and_return(build(:store, id: 2))
      Store.should_receive(:active).and_return(Store)

      Expenses::InventoryOut.any_instance.should_receive(:build_details)

      get :new, expense_id: 1, store_id: 2

      response.should be_success
      response.should render_template(:new)
    end
  end

  describe '/create' do
    it ":create" do
      Expense.stub_chain(:active, find: build(:expense, id: 1))
      Store.stub_chain(:active, find: build(:expense, id: 1))

      Expenses::InventoryOut.any_instance.should_receive(:create).and_return(true)

      post :create, expenses_inventory_out: { description: 'test', inventory_details_attributes: [{item_id: 1, quantity: 2}] }

      response.should redirect_to(expense_path(1))
      flash[:notice].should be_present
    end

    it ":create ERROR" do
      Expense.stub_chain(:active, find: build(:expense, id: 1))
      Store.stub_chain(:active, find: build(:expense, id: 1))

      Expenses::InventoryOut.any_instance.should_receive(:create).and_return(false)

      post :create, expenses_inventory_out: { description: 'test', inventory_details_attributes: [{item_id: 1, quantity: 2}] }

      response.should render_template(:new)
    end
  end
end
