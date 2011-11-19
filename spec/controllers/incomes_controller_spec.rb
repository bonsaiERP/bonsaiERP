require 'spec_helper'

describe IncomesController do
  def income_mock(stubs={})
    stubs = {id: 1, draft?: false}.merge(stubs)
    mock_model(Income, stubs)
  end

  before do
    controller.stub!(check_authorization!: true)
  end

  describe "check allow_transaction_action?" do
    it 'should allow edit to admin user' do
      session[:user] = {rol:"admin"}
      controller.allow_transaction_action?(income_mock).should be_true
    end

    it 'should not allow operations to edit' do
      session[:user] = {rol:"operations"}

      controller.allow_transaction_action?(income_mock).should be_false
    end

    it 'should allow operations and anybody to edit' do
      session[:user] = {rol:"operations"}
      m = income_mock(draft?: true)

      controller.allow_transaction_action?(m).should be_true
    end

    it 'should not allow other kind of roles' do
      session[:user] = {rol:"otherrol"}
      m = income_mock(draft?: true)

      controller.allow_transaction_action?(income_mock).should be_false
      
    end
  end

  describe "GET /incomes/:id/edit" do

    it 'should allow the user to edit' do
      Income.stub!(find: income_mock)
      session[:user] = {rol:"admin"}
      
      get :show, id: 1
      
      response.should_not be_redirect
    end

    it 'should NOT allow the user to edit' do
      Income.stub!(find: income_mock)
      session[:user] = {rol:"operations"}
      
      get :show, id: 1
      
      response.should redirect_to("/incomes/1")
    end
  end

  describe "PUT /incomes/:id" do

    it 'should allow the user to edit' do
      Income.stub!(find: income_mock(save_trans: false, 
            :attributes= => true, transaction_details: stub(build: true, any?: true)))
      session[:user] = {rol:"admin"}
      
      put :update, id: 1
      
      response.should_not be_redirect
      response.should render_template("edit")
    end

    it 'should NOT allow the user to edit' do
      Income.stub!(find: income_mock)
      session[:user] = {rol:"operations"}
      
      put :update, id: 1
      
      response.should redirect_to("/incomes/1")
    end
  end
end
