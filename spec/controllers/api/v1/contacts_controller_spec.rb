require 'spec_helper'

describe Api::V1::ContactsController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true)
    UserSession.user = build :user, id: 1
  end

  def create_contact
    create :contact
  end

  context 'GET #index' do
    it "OK" do
      create_contact

      get :index

      expect(json.size).to eq(1)
    end
  end

  context 'POST #create' do
    it "OK" do
      expect(Contact.count).to eq(0)
      post :create, contact: attributes_for(:contact)

      expect(response).to be_ok
      expect(Contact.count).to eq(1)
    end

    it "ERROR" do
      post :create, contact: {matchcode: ''}

      expect(response).to_not be_ok
    end
  end

  context 'GET #count' do
    it "count" do
      get :count

      expect(json['count']).to eq(0)
    end
  end

end
