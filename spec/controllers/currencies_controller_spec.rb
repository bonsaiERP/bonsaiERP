require 'spec_helper'

describe CurrenciesController do

  def mock_currency(stubs={})
    @mock_currency ||= mock_model(Currency, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all currencies as @currencies" do
      Currency.stub(:all) { [mock_currency] }
      get :index
      assigns(:currencies).should eq([mock_currency])
    end
  end

  describe "GET show" do
    it "assigns the requested currency as @currency" do
      Currency.stub(:find).with("37") { mock_currency }
      get :show, :id => "37"
      assigns(:currency).should be(mock_currency)
    end
  end

  describe "GET new" do
    it "assigns a new currency as @currency" do
      Currency.stub(:new) { mock_currency }
      get :new
      assigns(:currency).should be(mock_currency)
    end
  end

  describe "GET edit" do
    it "assigns the requested currency as @currency" do
      Currency.stub(:find).with("37") { mock_currency }
      get :edit, :id => "37"
      assigns(:currency).should be(mock_currency)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created currency as @currency" do
        Currency.stub(:new).with({'these' => 'params'}) { mock_currency(:save => true) }
        post :create, :currency => {'these' => 'params'}
        assigns(:currency).should be(mock_currency)
      end

      it "redirects to the created currency" do
        Currency.stub(:new) { mock_currency(:save => true) }
        post :create, :currency => {}
        response.should redirect_to(currency_url(mock_currency))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved currency as @currency" do
        Currency.stub(:new).with({'these' => 'params'}) { mock_currency(:save => false) }
        post :create, :currency => {'these' => 'params'}
        assigns(:currency).should be(mock_currency)
      end

      it "re-renders the 'new' template" do
        Currency.stub(:new) { mock_currency(:save => false) }
        post :create, :currency => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested currency" do
        Currency.should_receive(:find).with("37") { mock_currency }
        mock_currency.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :currency => {'these' => 'params'}
      end

      it "assigns the requested currency as @currency" do
        Currency.stub(:find) { mock_currency(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:currency).should be(mock_currency)
      end

      it "redirects to the currency" do
        Currency.stub(:find) { mock_currency(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(currency_url(mock_currency))
      end
    end

    describe "with invalid params" do
      it "assigns the currency as @currency" do
        Currency.stub(:find) { mock_currency(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:currency).should be(mock_currency)
      end

      it "re-renders the 'edit' template" do
        Currency.stub(:find) { mock_currency(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested currency" do
      Currency.should_receive(:find).with("37") { mock_currency }
      mock_currency.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the currencies list" do
      Currency.stub(:find) { mock_currency(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(currencies_url)
    end
  end

end
