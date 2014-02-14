require 'spec_helper'

describe ConfigurationsController do
  before(:each) do
    stub_auth
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index

      response.should be_success
    end
  end

end
