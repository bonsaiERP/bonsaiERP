require 'spec_helper'

describe LinksController do

  def mock_link(stubs={})
    @mock_link ||= mock_model(Link, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all links as @links" do
      Link.stub(:all) { [mock_link] }
      get :index
      assigns(:links).should eq([mock_link])
    end
  end

  describe "GET show" do
    it "assigns the requested link as @link" do
      Link.stub(:find).with("37") { mock_link }
      get :show, :id => "37"
      assigns(:link).should be(mock_link)
    end
  end

  describe "GET new" do
    it "assigns a new link as @link" do
      Link.stub(:new) { mock_link }
      get :new
      assigns(:link).should be(mock_link)
    end
  end

  describe "GET edit" do
    it "assigns the requested link as @link" do
      Link.stub(:find).with("37") { mock_link }
      get :edit, :id => "37"
      assigns(:link).should be(mock_link)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created link as @link" do
        Link.stub(:new).with({'these' => 'params'}) { mock_link(:save => true) }
        post :create, :link => {'these' => 'params'}
        assigns(:link).should be(mock_link)
      end

      it "redirects to the created link" do
        Link.stub(:new) { mock_link(:save => true) }
        post :create, :link => {}
        response.should redirect_to(link_url(mock_link))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved link as @link" do
        Link.stub(:new).with({'these' => 'params'}) { mock_link(:save => false) }
        post :create, :link => {'these' => 'params'}
        assigns(:link).should be(mock_link)
      end

      it "re-renders the 'new' template" do
        Link.stub(:new) { mock_link(:save => false) }
        post :create, :link => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested link" do
        Link.should_receive(:find).with("37") { mock_link }
        mock_link.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :link => {'these' => 'params'}
      end

      it "assigns the requested link as @link" do
        Link.stub(:find) { mock_link(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:link).should be(mock_link)
      end

      it "redirects to the link" do
        Link.stub(:find) { mock_link(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(link_url(mock_link))
      end
    end

    describe "with invalid params" do
      it "assigns the link as @link" do
        Link.stub(:find) { mock_link(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:link).should be(mock_link)
      end

      it "re-renders the 'edit' template" do
        Link.stub(:find) { mock_link(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested link" do
      Link.should_receive(:find).with("37") { mock_link }
      mock_link.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the links list" do
      Link.stub(:find) { mock_link(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(links_url)
    end
  end

end
