require 'spec_helper'

describe CountriesController do

  def mock_country(stubs={})
    @mock_country ||= mock_model(Country, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all countries as @countries" do
      Country.stub(:all) { [mock_country] }
      get :index
      assigns(:countries).should eq([mock_country])
    end
  end

  describe "GET show" do
    it "assigns the requested country as @country" do
      Country.stub(:find).with("37") { mock_country }
      get :show, :id => "37"
      assigns(:country).should be(mock_country)
    end
  end

  describe "GET new" do
    it "assigns a new country as @country" do
      Country.stub(:new) { mock_country }
      get :new
      assigns(:country).should be(mock_country)
    end
  end

  describe "GET edit" do
    it "assigns the requested country as @country" do
      Country.stub(:find).with("37") { mock_country }
      get :edit, :id => "37"
      assigns(:country).should be(mock_country)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created country as @country" do
        Country.stub(:new).with({'these' => 'params'}) { mock_country(:save => true) }
        post :create, :country => {'these' => 'params'}
        assigns(:country).should be(mock_country)
      end

      it "redirects to the created country" do
        Country.stub(:new) { mock_country(:save => true) }
        post :create, :country => {}
        response.should redirect_to(country_url(mock_country))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved country as @country" do
        Country.stub(:new).with({'these' => 'params'}) { mock_country(:save => false) }
        post :create, :country => {'these' => 'params'}
        assigns(:country).should be(mock_country)
      end

      it "re-renders the 'new' template" do
        Country.stub(:new) { mock_country(:save => false) }
        post :create, :country => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested country" do
        Country.should_receive(:find).with("37") { mock_country }
        mock_country.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :country => {'these' => 'params'}
      end

      it "assigns the requested country as @country" do
        Country.stub(:find) { mock_country(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:country).should be(mock_country)
      end

      it "redirects to the country" do
        Country.stub(:find) { mock_country(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(country_url(mock_country))
      end
    end

    describe "with invalid params" do
      it "assigns the country as @country" do
        Country.stub(:find) { mock_country(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:country).should be(mock_country)
      end

      it "re-renders the 'edit' template" do
        Country.stub(:find) { mock_country(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested country" do
      Country.should_receive(:find).with("37") { mock_country }
      mock_country.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the countries list" do
      Country.stub(:find) { mock_country(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(countries_url)
    end
  end

end
