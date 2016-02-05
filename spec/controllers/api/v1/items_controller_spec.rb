require 'spec_helper'

describe Api::V1::ItemsController do

  let(:user) { create :user }
  let(:link) { create :link, user_id: user.id, organisation_id: 10, tenant: 'amaru' }

  before(:each) do
    controller.stub(set_user_session: true)
    request.host = 'amaru.bonsaierp.com'
    UserSession.user = user
  end

  let(:unit) { create :unit }

  let(:item) { create :item, unit_id: unit.id }

  def items
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

      expect(json.size).to eq(2)
    end
  end

  context 'GET /api/v1/items/:id' do
    it "OK" do
      PgTools.should_receive(:change_schema).with(link.tenant)

      request.headers['token'] = link.api_token
      get :show, { id: item.id }, subdomain: 'amaru'

      expect(response).to be_ok

      expect(json['id']).to eq(item.id)
      expect(json['name']).to eq(item.name)
    end
  end

  context 'GET /api/v1/items/count/' do
    it "total" do
      request.headers['token'] = link.api_token
      get :count

      expect(json['count']).to eq(0)
    end
  end
end
