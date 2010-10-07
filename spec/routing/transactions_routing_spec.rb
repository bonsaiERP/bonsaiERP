require "spec_helper"

describe TransactionsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/transactions" }.should route_to(:controller => "transactions", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/transactions/new" }.should route_to(:controller => "transactions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/transactions/1" }.should route_to(:controller => "transactions", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/transactions/1/edit" }.should route_to(:controller => "transactions", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/transactions" }.should route_to(:controller => "transactions", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/transactions/1" }.should route_to(:controller => "transactions", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/transactions/1" }.should route_to(:controller => "transactions", :action => "destroy", :id => "1")
    end

  end
end
