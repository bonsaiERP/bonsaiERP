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

      expect(json.size).to eq(1)
    end
  end

  context 'GET :count' do
    it "count" do
      get :count

      expect(json['count']).to eq(0)
    end
  end
end
