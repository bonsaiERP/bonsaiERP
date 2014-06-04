require 'spec_helper'

describe Api::V1::TagsController do
  before(:each) do
    controller.stub(authenticate_user: true)
  end

  context 'GET :index' do
    it "/" do
      get :index, api_token: '111'
    end
  end
end
