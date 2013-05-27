require 'spec_helper'

describe InventoryInsController do
  before(:each) do
    stub_auth
  end
  let(:store) { build :store }
  let(:inventory) { build :inventory, id: 10 }

  describe 'GET /inventory_ins/new' do
    it 'OK' do
      Store.stub(find: store)

      get :new, store_id: 1

      response.should be_ok
      response.should render_template(:new)
      assigns(:inv).should be_is_a(Inventories::In)
      assigns(:inv).details.should have(1).item
    end

    it 'redirects' do
      get :new, store_id: 5

      response.should redirect_to(stores_path)
      flash[:error].should_not be_blank
    end
  end

  describe 'POST /inventory_ins' do
    it "OK" do
      Store.stub(find: store)
      Inventories::In.any_instance.stub(create: true, store: store, inventory: inventory, persisted?: true)

      post :create, store_id: 1, inventories_in: {date: '2013-05-10'}

      response.should redirect_to(inventory_path(10))
    end

    it 'Error' do
      Store.stub(find: store)
      Inventories::In.any_instance.stub(create: false, store: store)

      post :create, store_id: 1, inventories_in: {date: '2013-05-10'}

      response.should render_template(:new)
    end

    it "incorrect store" do
      Inventories::In.any_instance.stub(create: false, store: nil)

      post :create, store_id: 1, inventories_in: {date: '2013-05-10'}

      response.should redirect_to(stores_path)
      flash[:error].should_not be_blank
    end
  end
end
