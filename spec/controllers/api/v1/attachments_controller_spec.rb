require 'spec_helper'

describe Api::V1::AttachmentsController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true)
    UserSession.user = build :user, id: 1

    Income.any_instance.stub(valid?: true)
  end

  let(:item) {
    itm = build :item
    itm.stub(valid?: true, set_unit: true)
    itm.save
    itm
  }

  let(:attachment) {
    at = item.attachments.build(name: 'first.jpg', image: true)
    at.stub(valid?: true)
    at.save
    at
  }


  it "route" do
    expect(get: '/api/v1/attachments').to route_to(
      {
        controller: 'api/v1/attachments', action: 'index'
      }
    )
  end

  context 'GET #index' do
    it "OK" do
      attachment

      get :index

      %w(id name position image attachable_type created_at updated_at).each do |meth|
        expect(json[0][meth].present?).to eq(true)
      end
    end
  end

  context "GET #show" do
    it "route" do
      expect(get: "/api/v1/attachments/1").to route_to(
        controller: "api/v1/attachments", action: 'show', id: "1"
      )
    end

    it "spec_name" do
      get :show, id: attachment.id

      %w(id name position image attachable_type created_at updated_at).each do |meth|
        expect(json[meth].present?).to eq(true)
      end
    end
  end

  context "GET #count" do
    it "#count" do
      attachment

      get :count
      expect(json).to eq({'count' => 1})
    end
  end
end
