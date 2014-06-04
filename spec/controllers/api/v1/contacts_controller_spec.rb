require 'spec_helper'

describe Api::V1::ContactsController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true)
  end

  def create_contact
    UserSession.user = build :user, id: 1
    create :contact
  end

  context 'GET index' do
    it "OK" do
      create_contact

      get :index, api_token: '2323'

      json = JSON.parse(response.body)
      expect(json).to have(1).item
    end
  end
end
