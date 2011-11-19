require 'spec_helper'

describe BuysController do
  def buy_mock(stubs={})
    stubs = {id: 1, draft?: false}.merge(stubs)
    mock_model(Buy, stubs)
  end

  before do
    controller.stub!(check_authorization!: true)
  end

  describe "GET /buys/:id/edit" do

    it 'should allow the user to edit' do
      Buy.stub!(find: buy_mock)
      session[:user] = {rol:"admin"}
      
      get :edit, id: 1
      
      response.should_not be_redirect
    end

    it 'should render_template edit when draft?' do
      Buy.stub!(find: buy_mock(draft?: true))
      session[:user] = {rol:"admin"}
      
      get :edit, id: 1
      
      response.should render_template("edit")
    end

    it 'should render_template edit_trans when not draft?' do
      Buy.stub!(find: buy_mock)
      session[:user] = {rol:"admin"}
      
      get :edit, id: 1
      
      response.should render_template("edit_trans")
    end
  end

  describe "PUT /buys/:id" do

    it 'should allow the user to edit' do
      Buy.stub!(find: buy_mock(save_trans: false, 
            :attributes= => true, transaction_details: stub(build: true, any?: true)))
      
      put :update, id: 1
      
      response.should_not be_redirect
      response.should render_template("edit")
    end

    it 'should set the edit_trans template' do
      Buy.stub!(find: buy_mock(save_trans: false, draft?: true,
            :attributes= => true, transaction_details: stub(build: true, any?: true)))
      session[:user] = {rol:"admin"}
      
      put :update, id: 1
      
      response.should_not be_redirect
      response.should render_template("edit")
    end

    it 'should set the edit_trans template' do
      Buy.stub!(find: buy_mock(save_trans: false, draft?: false,
            :attributes= => true, transaction_details: stub(build: true, any?: true)))
      session[:user] = {rol:"admin"}
      
      put :update, id: 1
      
      response.should_not be_redirect
      response.should render_template("edit_trans")
    end

  end
end
