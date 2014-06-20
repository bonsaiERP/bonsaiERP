require 'spec_helper'

describe Api::V1::ItemsController do

  let(:user) { create :user }
  let(:link) { create :link, user_id: user.id, organisation_id: 10, tenant: 'amaru' }

   before(:each) do
     controller.stub(set_user_session: true)
     request.host = 'amaru.bonsaierp.com'
   end

  def items
    UserSession.user = user
    unit = create :unit, name: 'unit'
    item1 = create :item, unit_id: unit.id
    item2 = create :item, name: 'Other', unit_id: unit.id, code: '123423'

    [item1, item2]
  end

  context 'GET /api/v1/items' do
    it "/" do
      PgTools.should_receive(:change_schema).with(link.tenant)

      request.headers['token'] = link.api_token
      get :index, subdomain: 'amaru'

      expect(response).to be_ok
    end


    it "with items" do
      items
      request.headers['token'] = link.api_token
      get :index, api_token: link.api_token

      json = JSON.parse response.body
      expect(json['items']).to have(2).items
      expect(json['pagination']['total']).to eq(2)
      expect(json['pagination']['pages']).to eq(1)
      expect(json['pagination']['page']).to eq(1)
    end
  end
end
