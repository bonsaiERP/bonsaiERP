require 'spec_helper'

describe TaxesController do

  def mock_tax(stubs={})
    @mock_tax ||= mock_model(Tax, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all taxes as @taxes" do
      Tax.stub(:all) { [mock_tax] }
      get :index
      assigns(:taxes).should eq([mock_tax])
    end
  end

  describe "GET show" do
    it "assigns the requested tax as @tax" do
      Tax.stub(:find).with("37") { mock_tax }
      get :show, :id => "37"
      assigns(:tax).should be(mock_tax)
    end
  end

  describe "GET new" do
    it "assigns a new tax as @tax" do
      Tax.stub(:new) { mock_tax }
      get :new
      assigns(:tax).should be(mock_tax)
    end
  end

  describe "GET edit" do
    it "assigns the requested tax as @tax" do
      Tax.stub(:find).with("37") { mock_tax }
      get :edit, :id => "37"
      assigns(:tax).should be(mock_tax)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created tax as @tax" do
        Tax.stub(:new).with({'these' => 'params'}) { mock_tax(:save => true) }
        post :create, :tax => {'these' => 'params'}
        assigns(:tax).should be(mock_tax)
      end

      it "redirects to the created tax" do
        Tax.stub(:new) { mock_tax(:save => true) }
        post :create, :tax => {}
        response.should redirect_to(taxis_url(mock_tax))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tax as @tax" do
        Tax.stub(:new).with({'these' => 'params'}) { mock_tax(:save => false) }
        post :create, :tax => {'these' => 'params'}
        assigns(:tax).should be(mock_tax)
      end

      it "re-renders the 'new' template" do
        Tax.stub(:new) { mock_tax(:save => false) }
        post :create, :tax => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested tax" do
        Tax.should_receive(:find).with("37") { mock_tax }
        mock_tax.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :tax => {'these' => 'params'}
      end

      it "assigns the requested tax as @tax" do
        Tax.stub(:find) { mock_tax(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:tax).should be(mock_tax)
      end

      it "redirects to the tax" do
        Tax.stub(:find) { mock_tax(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(taxis_url(mock_tax))
      end
    end

    describe "with invalid params" do
      it "assigns the tax as @tax" do
        Tax.stub(:find) { mock_tax(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:tax).should be(mock_tax)
      end

      it "re-renders the 'edit' template" do
        Tax.stub(:find) { mock_tax(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested tax" do
      Tax.should_receive(:find).with("37") { mock_tax }
      mock_tax.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the taxes list" do
      Tax.stub(:find) { mock_tax(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(taxes_url)
    end
  end

end
