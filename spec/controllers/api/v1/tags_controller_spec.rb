require 'spec_helper'

describe Api::V1::TagsController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true)
  end

  context 'GET :index' do
    it "/" do
      get :index, api_token: '111'

      expect(response).to be_ok
      expect(response.body).to eq('[]')
    end

    it "with tags" do
      create :tag

      get :index, api_token: '1212'

      json = JSON.parse(response.body)
      expect(json).to have(1).item
    end
  end
end
