require "spec_helper"

describe InventoryOperationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/inventory_operations" }.should route_to(:controller => "inventory_operations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/inventory_operations/new" }.should route_to(:controller => "inventory_operations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/inventory_operations/1" }.should route_to(:controller => "inventory_operations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/inventory_operations/1/edit" }.should route_to(:controller => "inventory_operations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/inventory_operations" }.should route_to(:controller => "inventory_operations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/inventory_operations/1" }.should route_to(:controller => "inventory_operations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/inventory_operations/1" }.should route_to(:controller => "inventory_operations", :action => "destroy", :id => "1")
    end

  end
end
