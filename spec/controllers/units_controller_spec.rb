require 'spec_helper'

describe UnitsController do

  def mock_unit(stubs={})
    @mock_unit ||= mock_model(Unit, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all units as @units" do
      Unit.stub(:all) { [mock_unit] }
      get :index
      assigns(:units).should eq([mock_unit])
    end
  end

  describe "GET show" do
    it "assigns the requested unit as @unit" do
      Unit.stub(:find).with("37") { mock_unit }
      get :show, :id => "37"
      assigns(:unit).should be(mock_unit)
    end
  end

  describe "GET new" do
    it "assigns a new unit as @unit" do
      Unit.stub(:new) { mock_unit }
      get :new
      assigns(:unit).should be(mock_unit)
    end
  end

  describe "GET edit" do
    it "assigns the requested unit as @unit" do
      Unit.stub(:find).with("37") { mock_unit }
      get :edit, :id => "37"
      assigns(:unit).should be(mock_unit)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created unit as @unit" do
        Unit.stub(:new).with({'these' => 'params'}) { mock_unit(:save => true) }
        post :create, :unit => {'these' => 'params'}
        assigns(:unit).should be(mock_unit)
      end

      it "redirects to the created unit" do
        Unit.stub(:new) { mock_unit(:save => true) }
        post :create, :unit => {}
        response.should redirect_to(unit_url(mock_unit))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved unit as @unit" do
        Unit.stub(:new).with({'these' => 'params'}) { mock_unit(:save => false) }
        post :create, :unit => {'these' => 'params'}
        assigns(:unit).should be(mock_unit)
      end

      it "re-renders the 'new' template" do
        Unit.stub(:new) { mock_unit(:save => false) }
        post :create, :unit => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested unit" do
        Unit.should_receive(:find).with("37") { mock_unit }
        mock_unit.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :unit => {'these' => 'params'}
      end

      it "assigns the requested unit as @unit" do
        Unit.stub(:find) { mock_unit(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:unit).should be(mock_unit)
      end

      it "redirects to the unit" do
        Unit.stub(:find) { mock_unit(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(unit_url(mock_unit))
      end
    end

    describe "with invalid params" do
      it "assigns the unit as @unit" do
        Unit.stub(:find) { mock_unit(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:unit).should be(mock_unit)
      end

      it "re-renders the 'edit' template" do
        Unit.stub(:find) { mock_unit(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested unit" do
      Unit.should_receive(:find).with("37") { mock_unit }
      mock_unit.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the units list" do
      Unit.stub(:find) { mock_unit(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(units_url)
    end
  end

end
