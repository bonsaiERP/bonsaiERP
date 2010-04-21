require 'spec_helper'

describe ItemsController do

  def mock_item(stubs={})
    @mock_item ||= mock_model(Item, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all items as @items" do
      Item.stub(:all) { [mock_item] }
      get :index
      assigns(:items).should eq([mock_item])
    end
  end

  describe "GET show" do
    it "assigns the requested item as @item" do
      Item.stub(:find).with("37") { mock_item }
      get :show, :id => "37"
      assigns(:item).should be(mock_item)
    end
  end

  describe "GET new" do
    it "assigns a new item as @item" do
      Item.stub(:new) { mock_item }
      get :new
      assigns(:item).should be(mock_item)
    end
  end

  describe "GET edit" do
    it "assigns the requested item as @item" do
      Item.stub(:find).with("37") { mock_item }
      get :edit, :id => "37"
      assigns(:item).should be(mock_item)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created item as @item" do
        Item.stub(:new).with({'these' => 'params'}) { mock_item(:save => true) }
        post :create, :item => {'these' => 'params'}
        assigns(:item).should be(mock_item)
      end

      it "redirects to the created item" do
        Item.stub(:new) { mock_item(:save => true) }
        post :create, :item => {}
        response.should redirect_to(item_url(mock_item))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved item as @item" do
        Item.stub(:new).with({'these' => 'params'}) { mock_item(:save => false) }
        post :create, :item => {'these' => 'params'}
        assigns(:item).should be(mock_item)
      end

      it "re-renders the 'new' template" do
        Item.stub(:new) { mock_item(:save => false) }
        post :create, :item => {}
        response.should render_template(:new)
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested item" do
        Item.should_receive(:find).with("37") { mock_item }
        mock_item.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :item => {'these' => 'params'}
      end

      it "assigns the requested item as @item" do
        Item.stub(:find) { mock_item(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:item).should be(mock_item)
      end

      it "redirects to the item" do
        Item.stub(:find) { mock_item(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(item_url(mock_item))
      end
    end

    describe "with invalid params" do
      it "assigns the item as @item" do
        Item.stub(:find) { mock_item(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:item).should be(mock_item)
      end

      it "re-renders the 'edit' template" do
        Item.stub(:find) { mock_item(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template(:edit)
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested item" do
      Item.should_receive(:find).with("37") { mock_item }
      mock_item.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the items list" do
      Item.stub(:find) { mock_item(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(items_url)
    end
  end

end
