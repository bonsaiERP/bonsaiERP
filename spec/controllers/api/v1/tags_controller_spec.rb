require 'spec_helper'

describe Api::V1::TagsController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true)
  end

  context 'GET :index' do
    it "/" do
      get :index, api_token: '111'

      expect(response).to be_ok
    end

    it "with tags" do
      create :tag

      get :index, api_token: '1212'

      json = JSON.parse(response.body)
      expect(json['tags']).to have(1).item
      expect(json['pagination']['total']).to eq(1)
    end
  end
end
