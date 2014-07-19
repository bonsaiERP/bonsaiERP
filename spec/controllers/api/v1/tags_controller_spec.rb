require 'spec_helper'

describe Api::V1::TagsController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true, current_user: build(:user))
  end

  context 'GET :index' do
    it "/" do
      get :index

      expect(response).to be_ok
    end

    it "with tags" do
      create :tag

      get :index

      json = JSON.parse(response.body)
      expect(json).to have(1).item
    end
  end

  context 'GET :count' do
    it "count" do
      get :count

      resp = JSON.parse(response.body)
      expect(resp['count']).to eq(0)
    end
  end
end
