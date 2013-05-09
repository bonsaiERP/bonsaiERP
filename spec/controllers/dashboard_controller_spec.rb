require 'spec_helper'

describe DashboardController do
  before(:each) do
    stub_auth
  end

  describe 'GET /dashboard' do
    it "correct" do
      get :index

      response.should be_ok
      flash[:error].should be_blank
    end

    it "presents flash error" do
      get :index, date_start: ''

      response.should be_ok
      flash[:error].should_not be_blank
    end
  end
end
