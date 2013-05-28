require 'spec_helper'

describe ExpensesInventoryInsController do
  before(:each) do
    stub_auth
  end

  let(:store) { build :store, id: 1 }
  let(:expense) { build :expense, id: 2 }
  let(:inventory) { build :inventory, id: 1 }

  context 'GET /new' do
    it "should_rdirect" do
      get :new

      response.should redirect_to(expenses_path)
    end

    it "renders OK" do
      Store.stub_chain(:active, :find).with("1").and_return(store)
      Expense.stub_chain(:inventory, :find).with("2").and_return(expense)

      Expenses::InventoryIn.any_instance.should_receive(:build_details)

      get :new, store_id: 1, expense_id: 2

      response.should be_ok
    end
  end

  context 'POST /create' do
    it "#create" do
      Store.stub_chain(:active, :find).with("1").and_return(store)
      Expense.stub_chain(:inventory, :find).with("2").and_return(expense)
      Expenses::InventoryIn.any_instance.stub(create: true, inventory: inventory)

      post :create, store_id: 1, expense_id: 2, expenses_inventory_in: {}

      response.should redirect_to(inventory_path(1))
    end
  end
end
