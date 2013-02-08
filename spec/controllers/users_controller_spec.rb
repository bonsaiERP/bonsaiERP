require 'spec_helper'

describe UsersController do
  before(:each) do
    stub_auth
  end

  describe "GET show" do
    it "#show" do
      get :show, id: 0

      response.should be_success
      response.should render_template 'show'
    end
  end

end
