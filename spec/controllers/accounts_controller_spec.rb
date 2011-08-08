require 'spec_helper'

describe AccountsController do
  before(:each) do
    stub_auth
  end

  describe "GET /accounts/:id" do
    before do
      Account.stubs(:org => stub(:find => Account.new {|a| a.id = 1}))
    end

    it '' do
      
    end
  end

end
