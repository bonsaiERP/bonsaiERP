require 'spec_helper'

describe InventoryInsController do
  before(:each) do
    stub_auth
  end
  let(:store) { build :store }
  let(:io) { build :inventory_operation, id: 10 }

  describe 'GET /inventory_ins/new' do
    it 'OK' do
      Store.should_receive(:where).with(id: 1).and_return([store])
      Store.should_receive(:active).and_return(Store)

      get :new, store_id: 1

      response.should be_ok
      response.should render_template(:new)
      assigns(:inv).store.should be_is_a(Store)
      assigns(:inv).should be_is_a(InventoryIn)
      assigns(:inv).items.should have(1).item
    end

    it 'redirects' do
      get :new, store_id: 5

      response.should redirect_to(stores_path)
      flash[:error].should_not be_blank
    end
  end

  describe 'POST /inventory_ins' do
    it "OK" do
      InventoryIn.any_instance.stub(create: true, store: store, inventory_operation: io, persisted?: true)

      post :create, inventory_in: {date: '2013-05-10'}

      response.should redirect_to(inventory_operation_path(10))
    end

    it 'Error' do
      InventoryIn.any_instance.stub(create: false, store: store)

      post :create, inventory_in: {date: '2013-05-10'}

      response.should render_template(:new)
    end

    it "incorrect store" do
      InventoryIn.any_instance.stub(create: false, store: nil)

      post :create, inventory_in: {date: '2013-05-10'}

      response.should redirect_to(stores_path)
      flash[:error].should_not be_blank
    end
  end
end
