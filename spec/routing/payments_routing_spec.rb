require "spec_helper"

describe PaymentsController do
  describe "routing" do

    it "#new_income" do
      { :get => "/payments/1/new_income" }.should route_to(:controller => "payments", :action => "new_income", id: '1')
    end

  end
end
