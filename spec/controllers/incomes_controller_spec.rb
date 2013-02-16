require 'spec_helper'

describe IncomesController do
  before do
    stub_auth
    controller.stub(currency: 'BOB')
  end

  describe "GET /item/new" do
    it "initializes" do
      get :new

      response.should render_template('new')
      assigns(:income).currency.should eq('BOB')
    end
  end

  describe "POST /incomes" do
    let(:income) do
      inc = build(:income, id: 1)
      inc.stub(persisted?: true)
      inc
    end

    before(:each) do
      DefaultIncome.any_instance.stub(income: income)
    end

    it "creates_and_approves" do
      raise "Invalid DefaultIncome#create method doesn't exist" unless DefaultIncome.method_defined?(:create_and_approve)
      DefaultIncome.any_instance.should_receive(:create).and_return(true)

      post :create, income: {currency: 'BOB'}, commit_approve: 'Com Save'

      response.should redirect_to(income_path(1))
    end
  end

  describe "PUT /incomes/:id" do
    let(:income) do
      inc = build(:income, id: 1)
      inc.stub(persisted?: true)
      inc
    end

    it "updates" do
      Income.stub(find: income)
      DefaultIncome.any_instance.should_receive(:update).and_return(true)

      put :update,  id: 1, income: {currency: 'BOB'}

      response.should redirect_to(income_path(1))
      flash[:notice].should eq('El Ingreso fue actualizado!.')
    end

    it "updates_and_approves" do
      Income.stub(find: income)
      DefaultIncome.any_instance.should_receive(:update_and_approve).and_return(true)

      put :update,  id: 1, commit_approve: 'Save', income: {currency: 'BOB'}

      response.should redirect_to(income_path(1))
      flash[:notice].should eq('El Ingreso fue actualizado!.')
    end
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
