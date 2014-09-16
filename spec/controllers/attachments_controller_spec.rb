require 'spec_helper'

describe AttachmentsController do
  let(:item) {
    item = build :item
    item.stub(valid?: true)
    item.save
    item
  }

  describe 'POST #create' do
    it "OK" do
      post :create
    end
  end

  describe 'PATCH #update' do
    pending 'Tests'
  end

  describe 'DELETE #destroy' do
    pending 'Tests'
  end
end
