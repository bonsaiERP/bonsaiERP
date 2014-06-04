require 'spec_helper'

describe Api::V1::ItemsController do

  let(:user) { create :user }
  let(:link) { create :link, user_id: user.id, organisation_id: 10, tenant: 'amaru' }

  def items
    UserSession.user = user
    unit = create :unit, name: 'unit'
    item1 = create :item, unit_id: unit.id
    item2 = create :item, name: 'Other', unit_id: unit.id, code: '123423'

    [item1, item2]
  end

  context 'GET /api/v1/items' do
    it "/" do
      get :index, api_token: link.api_token

      expect(response).to be_ok
      expect(response.body).to eq('[]')
    end


    it "with items" do
      items
      get :index, api_token: link.api_token

      json = JSON.parse response.body
      expect(json).to have(2).items
    end
  end
end
