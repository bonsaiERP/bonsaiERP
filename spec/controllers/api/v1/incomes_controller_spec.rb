require 'spec_helper'

describe Api::V1::IncomesController do
  before(:each) do
    controller.stub(authenticate_user: true, set_tenant: true, set_user_session: true)
    UserSession.user = build :user, id: 1

    Income.any_instance.stub(valid?: true)
    IncomeDetail.any_instance.stub(valid?: true)
    Item.stub_chain(:where, pluck: [[1, 10], [2, 20.0]])

  end

  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }
  let(:today) { Date.today }

  let(:tag) { create :tag }

  let(:valid_params) { {
      date: today, due_date: (today + 3.days), contact_id: 1,
      currency: 'BOB', bill_number: "I-0001", description: "New income description", tag_ids: [tag.id.to_s],
      income_details_attributes: details
    }
  }

  context 'GET #show' do
    it "OK" do
      inc = Income.create(valid_params)

      inc.should be_persisted

      get :show, id: inc.id

      expect(json['id']).to eq(inc.id)
      expect(json['income_details'].size).to eq(2)
    end
  end

  context 'POST' do
    it "OK" do
      post :create, { income: valid_params }

      expect(json['id']).to be_is_a(Integer)
      expect(json['tag_ids']).to eq([tag.id])
    end
  end
end
