require "spec_helper"

describe AccountBalancesController do
  describe "routing" do

    it "routes to #index" do
      get("/account_balances").should route_to("account_balances#index")
    end

    it "routes to #new" do
      get("/account_balances/new").should route_to("account_balances#new")
    end

    it "routes to #show" do
      get("/account_balances/1").should route_to("account_balances#show", :id => "1")
    end

    it "routes to #edit" do
      get("/account_balances/1/edit").should route_to("account_balances#edit", :id => "1")
    end

    it "routes to #create" do
      post("/account_balances").should route_to("account_balances#create")
    end

    it "routes to #update" do
      put("/account_balances/1").should route_to("account_balances#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/account_balances/1").should route_to("account_balances#destroy", :id => "1")
    end

  end
end
