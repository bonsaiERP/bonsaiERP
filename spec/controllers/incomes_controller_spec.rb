require 'spec_helper'

describe IncomesController do
  def income_mock(stubs={})
    stubs = {id: 1, draft?: false}.merge(stubs)
    mock_model(Income, stubs)
  end

  before do
    controller.stub!(check_authorization!: true, set_tenant: true, currency_id: 1)
  end

  describe "GET /item/new" do
    it "initializes" do
      get :new

      assigns(:income).date.should be_a(Date)
      assigns(:income).ref_number.should_not be_blank
      assigns(:income).currency_id.should eq(1)
      assigns(:income).transaction_details.should_not be_empty

      response.should render_template('new')
    end
  end

  describe "POST /item" do

  end

  #describe "check allow_transaction_action?" do
    #it 'should allow edit to admin user' do
      #session[:user] = {rol:"admin"}
      #controller.allow_transaction_action?(income_mock).should be_true
    #end

    #it 'should not allow operations to edit' do
      #session[:user] = {rol:"operations"}

      #controller.allow_transaction_action?(income_mock).should be_false
    #end

    #it 'should allow operations and anybody to edit' do
      #session[:user] = {rol:"operations"}
      #m = income_mock(draft?: true)

      #controller.allow_transaction_action?(m).should be_true
    #end

    #it 'should not allow other kind of roles' do
      #session[:user] = {rol:"otherrol"}
      #m = income_mock(draft?: true)

      #controller.allow_transaction_action?(income_mock).should be_false
      
    #end
  #end

  #describe "GET /incomes/:id/edit" do

  #  it 'should allow the user to edit' do
  #    Income.stub!(find: income_mock)
  #    session[:user] = {rol:"admin"}
  #    
  #    get :edit, id: 1
  #    
  #    response.should_not be_redirect
  #  end

  #  it 'should NOT allow the user to edit' do
  #    Income.stub!(find: income_mock)
  #    session[:user] = {rol:"operations"}
  #    
  #    get :edit, id: 1
  #    
  #    response.should redirect_to("/incomes/1")
  #  end

  #  it 'should render_template edit when draft?' do
  #    Income.stub!(find: income_mock(draft?: true))
  #    session[:user] = {rol:"admin"}
  #    
  #    get :edit, id: 1
  #    
  #    response.should render_template("edit")
  #  end

  #  it 'should render_template edit_trans when not draft?' do
  #    Income.stub!(find: income_mock)
  #    session[:user] = {rol:"admin"}
  #    
  #    get :edit, id: 1
  #    
  #    response.should render_template("edit_trans")
  #  end
  #end

  #describe "PUT /incomes/:id" do

  #  it 'should allow the user to edit' do
  #    Income.stub!(find: income_mock(save_trans: false, 
  #          :attributes= => true, transaction_details: stub(build: true, any?: true)))
  #    session[:user] = {rol:"admin"}
  #    
  #    put :update, id: 1
  #    
  #    response.should_not be_redirect
  #    response.should render_template("edit")
  #  end

  #  it 'should set the edit_trans template' do
  #    Income.stub!(find: income_mock(save_trans: false, draft?: true,
  #          :attributes= => true, transaction_details: stub(build: true, any?: true)))
  #    session[:user] = {rol:"admin"}
  #    
  #    put :update, id: 1
  #    
  #    response.should_not be_redirect
  #    response.should render_template("edit")
  #  end

  #  it 'should set the edit_trans template' do
  #    Income.stub!(find: income_mock(save_trans: false, draft?: false,
  #          :attributes= => true, transaction_details: stub(build: true, any?: true)))
  #    session[:user] = {rol:"admin"}
  #    
  #    put :update, id: 1
  #    
  #    response.should_not be_redirect
  #    response.should render_template("edit_trans")
  #  end

  #  it 'should NOT allow the user to edit' do
  #    Income.stub!(find: income_mock)
  #    session[:user] = {rol:"operations"}
  #    
  #    put :update, id: 1
  #    
  #    response.should redirect_to("/incomes/1")
  #  end
  #end
end
