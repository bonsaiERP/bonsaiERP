require "spec_helper"

describe CurrencyRatesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/currency_rates" }.should route_to(:controller => "currency_rates", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/currency_rates/new" }.should route_to(:controller => "currency_rates", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/currency_rates/1" }.should route_to(:controller => "currency_rates", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/currency_rates/1/edit" }.should route_to(:controller => "currency_rates", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/currency_rates" }.should route_to(:controller => "currency_rates", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/currency_rates/1" }.should route_to(:controller => "currency_rates", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/currency_rates/1" }.should route_to(:controller => "currency_rates", :action => "destroy", :id => "1")
    end

  end
end
