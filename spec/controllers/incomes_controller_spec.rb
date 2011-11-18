require 'spec_helper'

describe IncomesController do
  def income_mock(stubs={})
    stubs = {id: 1, draft?: false}.merge(stubs)
    mock_model(Income, stubs)
  end

  describe "GET show /incomes/:id" do
    it 'should allow edit to admin user' do
      session[:user] = {rol:"admin"}
      #Income.stub!(find: income_mock(draft?: false))
    
      #get :show, id: 1
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

end
