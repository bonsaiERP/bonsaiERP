require 'spec_helper'

describe ItemsController do
  let(:user) { build :user, id: 10}

  before(:each) do
    stub_auth
    controller.stub(current_tenant: 'public')
    UserSession.user = user
  end

  let(:item) { build :item, id: 37 }
  let(:unit) { create :unit }
  let(:item_attrs) { attributes_for(:item).merge(unit_id: unit.id) }

  describe "GET index" do
    it "assigns all items as @items" do
      get :index

      assigns(:items).should eq([])
    end
  end

  describe "GET show" do
    it "assigns the requested item as @item" do
      Item.stub(:find).with("37").and_return(item)

      get :show, :id => "37"
      assigns(:item).should be(item)
    end
  end

  describe "GET new" do
    it "assigns a new item as @item" do
      get :new
      assigns(:item).class.should be(Item)
    end
  end

  describe "GET edit" do
    it "assigns the requested item as @item" do
      Item.stub(:find).with("37").and_return(item)

      get :edit, :id => "37"
      assigns(:item).should be(item)
    end
  end

  describe "POST create" do

    it "OK" do
      post :create, :item => item_attrs

      expect(assigns(:item).class).to be(Item)
      expect(assigns(:item).persisted?).to be(true)
      _id = assigns(:item).id
      expect(response.redirect?).to eq(true)
      expect(response.redirect_url).to eq(controller.item_url(_id))
    end

    it 'ERROR' do
      post :create, :item => {name: 'test'}

      expect(response.redirect?).to be(false)
      expect(response).to render_template(:new)
      expect(assigns(:item).errors.messages.present?).to be(true)
    end

  end

  describe "PUT update" do
    let(:item) { create :item, unit_id: unit.id  }

    it 'OK' do
      put :update, id: item.id, item: item.attributes.merge(name: 'A new name for the item')

      _item = assigns(:item)
      expect(response.redirect_url).to eq(controller.item_url(item.id))
      expect(_item.name).to eq('A new name for the item')
    end

    it 'ERROR' do
      put :update, id: item.id, item: item.attributes.merge(name: '')

      _item = assigns(:item)

      expect(response).to render_template(:edit)
      expect(_item.errors.messages.present?).to eq(true)
    end
  end

  describe "DELETE destroy" do
    it "OK" do
      item.unit_id = unit.id

      expect(item.save).to eq(true)
      expect(Item.count).to eq(1)

      delete :destroy, :id => item.id

      expect(Item.count).to eq(0)
      expect(response).to redirect_to(controller.items_path)
    end
  end

end
