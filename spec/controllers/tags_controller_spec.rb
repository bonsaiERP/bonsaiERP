require 'spec_helper'

describe TagsController do
  before(:each) do
    stub_auth
  end

  context 'create' do
    it 'create' do
      post :create, tag: {name: 'test', bgcolor: '#ff0000'}

      assigns(:tag).should be_is_a(Tag)
      t = assigns(:tag)
      expect(response.body).to eq(t.to_json.to_s)
    end

    it 'create error' do
      post :create, tag: {name: 'test', bgcolor: '123'}

      t = assigns(:tag)

      expect(response.body).to eq({errors: t.errors}.to_json.to_s)
    end
  end
end
