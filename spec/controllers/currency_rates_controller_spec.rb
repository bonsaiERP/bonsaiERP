require 'spec_helper'

describe CurrencyRatesController do

  def mock_currency_rate(stubs={})
    (@mock_currency_rate ||= mock_model(CurrencyRate).as_null_object).tap do |currency_rate|
      currency_rate.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all currency_rates as @currency_rates" do
      CurrencyRate.stub(:all) { [mock_currency_rate] }
      get :index
      assigns(:currency_rates).should eq([mock_currency_rate])
    end
  end

  describe "GET show" do
    it "assigns the requested currency_rate as @currency_rate" do
      CurrencyRate.stub(:find).with("37") { mock_currency_rate }
      get :show, :id => "37"
      assigns(:currency_rate).should be(mock_currency_rate)
    end
  end

  describe "GET new" do
    it "assigns a new currency_rate as @currency_rate" do
      CurrencyRate.stub(:new) { mock_currency_rate }
      get :new
      assigns(:currency_rate).should be(mock_currency_rate)
    end
  end

  describe "GET edit" do
    it "assigns the requested currency_rate as @currency_rate" do
      CurrencyRate.stub(:find).with("37") { mock_currency_rate }
      get :edit, :id => "37"
      assigns(:currency_rate).should be(mock_currency_rate)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created currency_rate as @currency_rate" do
        CurrencyRate.stub(:new).with({'these' => 'params'}) { mock_currency_rate(:save => true) }
        post :create, :currency_rate => {'these' => 'params'}
        assigns(:currency_rate).should be(mock_currency_rate)
      end

      it "redirects to the created currency_rate" do
        CurrencyRate.stub(:new) { mock_currency_rate(:save => true) }
        post :create, :currency_rate => {}
        response.should redirect_to(currency_rate_url(mock_currency_rate))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved currency_rate as @currency_rate" do
        CurrencyRate.stub(:new).with({'these' => 'params'}) { mock_currency_rate(:save => false) }
        post :create, :currency_rate => {'these' => 'params'}
        assigns(:currency_rate).should be(mock_currency_rate)
      end

      it "re-renders the 'new' template" do
        CurrencyRate.stub(:new) { mock_currency_rate(:save => false) }
        post :create, :currency_rate => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested currency_rate" do
        CurrencyRate.should_receive(:find).with("37") { mock_currency_rate }
        mock_currency_rate.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :currency_rate => {'these' => 'params'}
      end

      it "assigns the requested currency_rate as @currency_rate" do
        CurrencyRate.stub(:find) { mock_currency_rate(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:currency_rate).should be(mock_currency_rate)
      end

      it "redirects to the currency_rate" do
        CurrencyRate.stub(:find) { mock_currency_rate(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(currency_rate_url(mock_currency_rate))
      end
    end

    describe "with invalid params" do
      it "assigns the currency_rate as @currency_rate" do
        CurrencyRate.stub(:find) { mock_currency_rate(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:currency_rate).should be(mock_currency_rate)
      end

      it "re-renders the 'edit' template" do
        CurrencyRate.stub(:find) { mock_currency_rate(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested currency_rate" do
      CurrencyRate.should_receive(:find).with("37") { mock_currency_rate }
      mock_currency_rate.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the currency_rates list" do
      CurrencyRate.stub(:find) { mock_currency_rate }
      delete :destroy, :id => "1"
      response.should redirect_to(currency_rates_url)
    end
  end

end
