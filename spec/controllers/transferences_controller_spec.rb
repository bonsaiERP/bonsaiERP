require 'spec_helper'

describe TransferencesController do
  describe "GET /transferences/new?account_id" do
    it "renders the new" do
      AccountQuery.stub_chain(:bank_cash, where: [build(:bank)])

      get :new

      response.should render_template('new')
    end
  end
end
